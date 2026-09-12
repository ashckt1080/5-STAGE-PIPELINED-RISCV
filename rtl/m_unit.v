`timescale 1ns / 1ps
    
module m_unit(
    input clk,
    input rst,
    input start,
    input [31:0] a_in,
    input [31:0] b_in,
    input [2:0] funct3,
    output reg [31:0] result,
    output reg done,
    output reg busy
    );
        
    reg [31:0] a;
    reg [31:0] b;
    reg [2:0] opcode;
        
    reg [31:0] multiplicand;
    reg [63:0] accumulator;
    reg [5:0] counter;
    reg init_pending;
        
    wire a_is_signed = (opcode == 3'b001 || opcode == 3'b010 || opcode == 3'b100 || opcode == 3'b110);
    wire b_is_signed = (opcode == 3'b001 || opcode == 3'b100 || opcode == 3'b110);
        
    wire a_sign = a[31] & a_is_signed;
    wire b_sign = b[31] & b_is_signed;
    wire p_sign = a_sign ^ b_sign;
        
    wire [31:0] a_mag = (a_sign ? ~a + 32'b1 : a);
    wire [31:0] b_mag = (b_sign ? ~b + 32'b1 : b);
        
    wire [32:0] sum = {1'b0, accumulator[63:32]} + {1'b0, multiplicand};
    wire [32:0] diff = {1'b0, accumulator [62:31]} - {1'b0, multiplicand};
        
    wire [63:0] product = (p_sign ? ~accumulator + 64'b1 : accumulator);
        
    wire [31:0] raw_quotient = accumulator[31:0];
    wire [31:0] quotient = p_sign ? (~raw_quotient + 32'd1) : raw_quotient;
    wire [31:0] raw_remainder = accumulator[63:32];
    wire [31:0] remainder = a_sign ? (~raw_remainder + 32'd1) : raw_remainder;
        
    wire is_div = opcode[2];
    wire is_div_zero = is_div & (b == 0);
    wire is_sign_overflow = (opcode == 3'b100 || opcode == 3'b110) & (a == 32'h80000000) & (b == 32'hFFFFFFFF);
        
    always @ (posedge clk) begin
        
        if(rst) begin
        
            a <= 32'b0;
            b <= 32'b0;
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
                a <= a_in;
                b <= b_in;
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
                        result <= (opcode[1] ? a : 32'hFFFFFFFF);
                    end
            
                    else if(is_sign_overflow) begin
                        done <= 1'b1;
                        busy <= 1'b0;
                        result <= (opcode[1] ? 32'b0 : 32'h80000000);
                    end
            
                    else begin        
                        multiplicand <= (is_div ? b_mag : a_mag);
                        accumulator[31:0] <= (is_div ? a_mag : b_mag);
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
