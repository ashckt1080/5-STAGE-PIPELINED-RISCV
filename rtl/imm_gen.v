`timescale 1ns / 1ps

module imm_gen(
    input [31:0] instr,
    output reg [31:0] immediate
    ); 
    
    wire [6:0] opcode;
    assign opcode = instr[6:0];
    
    always @(*) begin
        case (opcode) 
            7'b0110011 : immediate = 32'b0;//R
            7'b0010011 : immediate = {{20{instr[31]}} ,instr[31:20]};//I
            7'b0000011 : immediate = {{20{instr[31]}} ,instr[31:20]};//I(load)
            7'b1100111 : immediate = {{20{instr[31]}} ,instr[31:20]};//I(jalr)
            7'b0100011 : immediate = {{20{instr[31]}} ,instr[31:25] ,instr[11:7]};//S
            7'b1100011 : immediate = {{19{instr[31]}} ,instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};//B
            7'b1101111 : immediate = {{11{instr[31]}} ,instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};//J(jal)
            7'b0110111 : immediate = {instr[31:12], 12'b0};//U(lui)
            7'b0010111 : immediate = {instr[31:12], 12'b0};//U(auipc)
            default : immediate = 32'b0;
        endcase
    end
                
endmodule
