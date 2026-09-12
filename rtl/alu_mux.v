`timescale 1ns / 1ps

module alu_mux(
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [31:0] pc,
    input [31:0] immediate,
    input [1:0] alu_a_src,
    input [1:0] alu_b_src,
    output reg [31:0] alu_a_out,
    output reg [31:0] alu_b_out
    ); 
    
    always@ (*) begin
    case (alu_a_src)
        2'b00 : alu_a_out = rs1_data;
        2'b01 : alu_a_out = pc;
        2'b10 : alu_a_out = 32'b0;
        default : alu_a_out = rs1_data;
    endcase
    end 
    
    always@ (*) begin
    case (alu_b_src)
        2'b00 : alu_b_out = rs2_data;
        2'b01 : alu_b_out = immediate;
        default : alu_b_out = rs2_data;
    endcase
    end
    
endmodule
