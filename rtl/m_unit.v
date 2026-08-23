`timescale 1ns / 1ps
    
module m_unit(
    input clk,
    input rst,
    input start,
    input [31:0] A_in,
    input [31:0] B_in,
    input [2:0] funct3,
    output reg [31:0] result,
    output reg done,
    output reg busy
    );
        
    reg [31:0] A;
    reg [31:0] B;
    reg [2:0] opcode;
        
    reg [31:0] multiplicand;
    reg [63:0] accumulator;
    reg [5:0] counter;
    reg init_pending;
        
    wire A_is_signed = (opcode == 3'b001 || opcode == 3'b010 || opcode == 3'b100 || opcode == 3'b110);
    wire B_is_signed = (opcode == 3'b001 || opcode == 3'b100 || opcode == 3'b110);
        
    wire A_sign = A[31] & A_is_signed;
    wire B_sign = B[31] & B_is_signed;
    wire P_sign = A_sign ^ B_sign; 
        
    wire [31:0] A_mag = (A_sign ? ~A + 32'b1 : A);
    wire [31:0] B_mag = (B_sign ? ~B + 32'b1 : B);
        
    wire [32:0] sum = {1'b0, accumulator[63:32]} + {1'b0, multiplicand};
    wire [32:0] diff = {1'b0, accumulator [62:31]} - {1'b0, multiplicand};
        
    wire [63:0] product = (P_sign ? ~accumulator + 64'b1 : accumulator);
        
    wire [31:0] raw_quotient = accumulator[31:0];
    wire [31:0] quotient = P_sign ? (~raw_quotient + 32'd1) : raw_quotient;
    wire [31:0] raw_remainder = accumulator[63:32];
    wire [31:0] remainder = A_sign ? (~raw_remainder + 32'd1) : raw_remainder;
        
    wire is_div = opcode[2];
    wire is_div_zero = is_div & (B == 0);
    wire is_sign_overflow = (opcode == 3'b100 || opcode == 3'b110) & (A == 32'h80000000) & (B == 32'hFFFFFFFF);
        
    always @ (posedge clk) begin
        
        if(rst) begin
        
            A <= 32'b0;
            B <= 32'b0;
            opcode <= 3'b0;
            
            multiplicand <= 32'b0;
            accumulator <= 64'b0;
            counter <= 6'b0;
            
            result <= 32'b0;
            done <= 1'b0;
            busy <= 1'b0;
            init_pending <= 1'b0;
        
        end
        
        else begin
        
            done <= 1'b0;
        
            if(start && !busy) begin
                A <= A_in;
                B <= B_in;
                opcode <= funct3;
                counter <= 6'b0;
                busy <= 1'b1;
                init_pending <= 1'b1;
            end
        
            else if (busy) begin
        
                if(init_pending) begin
                
                    init_pending <= 1'b0;
        
                    if(is_div_zero) begin
                        done <= 1'b1;
                        busy <= 1'b0;
                        result <= (opcode[1] ? A : 32'hFFFFFFFF);
                    end
            
                    else if(is_sign_overflow) begin
                        done <= 1'b1;
                        busy <= 1'b0;
                        result <= (opcode[1] ? 32'b0 : 32'h80000000);
                    end
            
                    else begin        
                        multiplicand <= (is_div ? B_mag : A_mag);
                        accumulator[31:0] <= (is_div ? A_mag : B_mag);
                        accumulator[63:32] <= 32'b0;      
                    end   
                end
        
                else begin     
                    if (counter < 6'd32) begin
            
                        if(is_div) begin 
                            if(diff[32] == 1'b1) begin
                                accumulator <= {accumulator[62:0], 1'b0};
                            end
              
                            else begin
                                accumulator <= {diff[31:0], accumulator[30:0], 1'b1};
                            end            
                        end
                
                        else begin     
                            if(accumulator[0]) begin
                                accumulator <= {sum, accumulator[31:1]};
                            end
                    
                            else begin
                                accumulator <= {1'b0, accumulator[63:1]};
                            end                     
                        end
                
                        counter <= counter + 1'b1;
           
                    end
            
                    if(counter == 6'd32) begin
                        busy <= 1'b0;
                        done <= 1'b1;
                
                        case (opcode)
                            3'b000 : result <= accumulator[31:0];
                            3'b001 : result <= product[63:32];
                            3'b010 : result <= product[63:32];
                            3'b011 : result <= product[63:32];
                            3'b100 : result <= quotient;
                            3'b101 : result <= raw_quotient;   
                            3'b110 : result <= remainder;
                            3'b111 : result <= raw_remainder;
                        endcase
                    end
                end      
            end    
        end      
    end
       
endmodule