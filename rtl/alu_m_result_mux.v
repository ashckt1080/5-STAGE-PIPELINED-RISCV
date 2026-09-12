`timescale 1ns / 1ps


module alu_m_result_mux(
    input [31:0] alu_out,
    input [31:0] m_out,
    input is_m_instr,
    output reg [31:0] alu_m_result
    );
    
    always@ (*) begin
        case(is_m_instr)
            1'b0 : alu_m_result = alu_out;
            1'b1 : alu_m_result = m_out;
            default : alu_m_result = alu_out;
        endcase
    end
endmodule
