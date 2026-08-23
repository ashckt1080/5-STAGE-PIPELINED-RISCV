`timescale 1ns / 1ps

module decoder(
    input [6:0] opcode,
    output reg reg_write,
    output reg mem_write,
    output reg mem_read,
    output reg branch,
    output reg jump,
    output reg [1:0] ALU_A_src,
    output reg [1:0] ALU_B_src,
    output reg [1:0] WB_src,
    output reg opcode_invalid,
    output reg rs1_used,
    output reg rs2_used
    );

    always @ (*) begin

        case (opcode)

        //R
        7'b0110011 : begin
            reg_write = 1'b1;
            mem_write = 1'b0;
            mem_read = 1'b0;
            branch = 1'b0;
            jump = 1'b0;
            ALU_A_src = 2'b00;//rs1
            ALU_B_src = 2'b00;//rs2
            WB_src = 2'b00;//ALU
            opcode_invalid = 1'b0;
            rs1_used = 1'b1;
            rs2_used = 1'b1;
        end

        //I
        7'b0010011 : begin
            reg_write = 1'b1;
            mem_write = 1'b0;
            mem_read = 1'b0;
            branch = 1'b0;
            jump = 1'b0;
            ALU_A_src = 2'b00;//rs1
            ALU_B_src = 2'b01;//immediate
            WB_src = 2'b00;//ALU
            opcode_invalid = 1'b0;
            rs1_used = 1'b1;
            rs2_used = 1'b0;
        end

        //I(load)
        7'b0000011 : begin
            reg_write = 1'b1;
            mem_write = 1'b0;
            mem_read = 1'b1;
            branch = 1'b0;
            jump = 1'b0;
            ALU_A_src = 2'b00;//rs1
            ALU_B_src = 2'b01;//immediate
            WB_src = 2'b01;//data memory
            opcode_invalid = 1'b0;
            rs1_used = 1'b1;
            rs2_used = 1'b0;
        end

        //S
        7'b0100011 : begin
            reg_write = 1'b0;
            mem_write = 1'b1;
            mem_read = 1'b0;
            branch = 1'b0;
            jump = 1'b0;
            ALU_A_src = 2'b00;//rs1
            ALU_B_src = 2'b01;//immediate
            WB_src = 2'b00;//unused
            opcode_invalid = 1'b0;
            rs1_used = 1'b1;
            rs2_used = 1'b1;
        end

        //B
        7'b1100011 : begin
            reg_write = 1'b0;
            mem_write = 1'b0;
            mem_read = 1'b0;
            branch = 1'b1;
            jump = 1'b0;
            ALU_A_src = 2'b00;//rs1
            ALU_B_src = 2'b00;//rs2
            WB_src = 2'b00;//unused
            opcode_invalid = 1'b0;
            rs1_used = 1'b1;
            rs2_used = 1'b1;
        end

        //J(jal)
        7'b1101111 : begin
            reg_write = 1'b1;
            mem_write = 1'b0;
            mem_read = 1'b0;
            branch = 1'b0;
            jump = 1'b1;
            ALU_A_src = 2'b01;//PC
            ALU_B_src = 2'b01;//immediate
            WB_src = 2'b10;//PC+4
            opcode_invalid = 1'b0;
            rs1_used = 1'b0;
            rs2_used = 1'b0;
        end

        //I(jalr)
        7'b1100111 : begin
            reg_write = 1'b1;
            mem_write = 1'b0;
            mem_read = 1'b0;
            branch = 1'b0;
            jump = 1'b1;
            ALU_A_src = 2'b00;//rs1
            ALU_B_src = 2'b01;//immediate
            WB_src = 2'b10;//PC+4
            opcode_invalid = 1'b0;
            rs1_used = 1'b1;
            rs2_used = 1'b0;
        end

        //U(lui)
        7'b0110111 : begin
            reg_write = 1'b1;
            mem_write = 1'b0;
            mem_read = 1'b0;
            branch = 1'b0;
            jump = 1'b0;
            ALU_A_src = 2'b10;//zero
            ALU_B_src = 2'b01;//immediate
            WB_src = 2'b00;//ALU
            opcode_invalid = 1'b0;
            rs1_used = 1'b0;
            rs2_used = 1'b0;
        end

        //U(auipc)
        7'b0010111 : begin
            reg_write = 1'b1;
            mem_write = 1'b0;
            mem_read = 1'b0;
            branch = 1'b0;
            jump = 1'b0;
            ALU_A_src = 2'b01;//PC
            ALU_B_src = 2'b01;//immediate
            WB_src = 2'b00;//ALU
            opcode_invalid = 1'b0;
            rs1_used = 1'b0;
            rs2_used = 1'b0;
        end

        default : begin
            reg_write = 1'b0;
            mem_write = 1'b0;
            mem_read = 1'b0;
            branch = 1'b0;
            jump = 1'b0;
            ALU_A_src = 2'b00;
            ALU_B_src = 2'b00;
            WB_src = 2'b00;
            opcode_invalid = 1'b1;
            rs1_used = 1'b0;
            rs2_used = 1'b0;
        end

        endcase
    end

endmodule