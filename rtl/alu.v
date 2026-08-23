`timescale 1ns / 1ps

module alu (
    input [31:0] A,
    input [31:0] B,
    input [3:0] opcode,

    output reg [31:0] result,
    output wire Z
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

    always @(*) begin
        case (opcode)

            ALU_ADD : result = A + B;
            ALU_SUB : result = A - B;
            ALU_OR : result = A | B;
            ALU_AND : result = A & B;
            ALU_XOR : result = A ^ B;
            ALU_SLL : result = A << B[4:0];
            ALU_SRL : result = A >> B[4:0];
            ALU_SRA : result = $signed(A) >>> B[4:0];
            ALU_SLTU : result = (A < B) ? 32'd1 : 32'd0;
            ALU_SLT : result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;

            default : result = 32'd0;
        endcase
    end

    assign Z = ~|result;

endmodule