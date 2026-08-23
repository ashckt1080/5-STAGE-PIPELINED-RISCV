`timescale 1ns / 1ps


module alu_m_result_mux(
    input [31:0] ex_ALU_out,
    input [31:0] ex_m_result,
    input ex_is_m_instr,
    output reg [31:0] alu_m_result
    );
    
    always@ (*) begin
        case(ex_is_m_instr)
            1'b0 : alu_m_result = ex_ALU_out;
            1'b1 : alu_m_result = ex_m_result;
            default : alu_m_result = ex_ALU_out;
        endcase
    end
endmodule
