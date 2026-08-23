`timescale 1ns / 1ps

module alu_decoder (
    input wire [31:0] instr,
    output reg [3:0] alu_op
);

    localparam [3:0] ALU_ADD = 4'b0000;
    localparam [3:0] ALU_SUB = 4'b0001;
    localparam [3:0] ALU_OR = 4'b0010;
    localparam [3:0] ALU_AND = 4'b0011;
    localparam [3:0] ALU_XOR = 4'b0100;
    localparam [3:0] ALU_SLL = 4'b0101;
    localparam [3:0] ALU_SRL = 4'b0110;
    localparam [3:0] ALU_SRA = 4'b0111;
    localparam [3:0] ALU_SLTU = 4'b1000;
    localparam [3:0] ALU_SLT = 4'b1001;

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    always @(*) begin

        case (opcode)
            7'b0110011: begin
                case (funct3)
                    3'b000: alu_op = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;//ADD,SUB
                    3'b001: alu_op = ALU_SLL;//SLL
                    3'b010: alu_op = ALU_SLT;//SLT
                    3'b011: alu_op = ALU_SLTU;//SLTU
                    3'b100: alu_op = ALU_XOR;//XOR
                    3'b101: alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;//SRA,SRL
                    3'b110: alu_op = ALU_OR;//OR
                    3'b111: alu_op = ALU_AND;//AND
                    default: alu_op = ALU_ADD;
                endcase
            end

            7'b0010011: begin
                case (funct3)
                    3'b000: alu_op = ALU_ADD;//ADDI
                    3'b001: alu_op = ALU_SLL;//SLLI
                    3'b010: alu_op = ALU_SLT;//SLTI
                    3'b011: alu_op = ALU_SLTU;//SLTIU
                    3'b100: alu_op = ALU_XOR;//XORI
                    3'b101: alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;//SRAI, SRLI
                    3'b110: alu_op = ALU_OR;//ORI
                    3'b111: alu_op = ALU_AND;//ANDI
                    default: alu_op = ALU_ADD;
                endcase
            end

            7'b0000011: alu_op = ALU_ADD;//LOAD
            7'b0100011: alu_op = ALU_ADD;//STORE
            7'b0110111: alu_op = ALU_ADD;//LUI
            7'b0010111: alu_op = ALU_ADD;//AUIPC
            7'b1101111: alu_op = ALU_ADD;//JAL
            7'b1100111: alu_op = ALU_ADD;//JALR

            7'b1100011: begin
                case (funct3)
                    3'b000: alu_op = ALU_SUB;//BEQ
                    3'b001: alu_op = ALU_SUB;//BNE
                    3'b100: alu_op = ALU_SLT;//BLT
                    3'b101: alu_op = ALU_SLT;//BGE
                    3'b110: alu_op = ALU_SLTU;//BLTU
                    3'b111: alu_op = ALU_SLTU;//BGEU
                    default: alu_op = ALU_ADD;
                endcase
            end

            default: alu_op = ALU_ADD;
        endcase
    end

endmodule
