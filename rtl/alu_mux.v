`timescale 1ns / 1ps

module alu_mux(
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [31:0] pc,
    input [31:0] immediate,
    input [1:0] ALU_A_src,
    input [1:0] ALU_B_src,
    output reg [31:0] ALU_A_out,
    output reg [31:0] ALU_B_out
    ); 
    
    always@ (*) begin
    case (ALU_A_src) 
        2'b00 : ALU_A_out = rs1_data;
        2'b01 : ALU_A_out = pc;
        2'b10 : ALU_A_out = 32'b0;
        default : ALU_A_out = rs1_data;
    endcase
    end 
    
    always@ (*) begin
    case (ALU_B_src) 
        2'b00 : ALU_B_out = rs2_data;
        2'b01 : ALU_B_out = immediate;
        default : ALU_B_out = rs2_data;
    endcase
    end
    
endmodule
