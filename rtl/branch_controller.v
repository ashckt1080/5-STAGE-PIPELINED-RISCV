`timescale 1ns / 1ps

module branch_controller(
    input [31:0] pc,
    input [31:0] immediate,
    input [2:0] funct3,
    input branch,
    input [31:0] forwarded_rs1,
    input [31:0] forwarded_rs2,
    output [31:0] branch_target,
    output branch_taken,
    input id_ex_valid_out
    );
    
    reg condition;

    localparam [2:0] BEQ  = 3'b000;
    localparam [2:0] BNE  = 3'b001;
    localparam [2:0] BLT  = 3'b100;
    localparam [2:0] BGE  = 3'b101;
    localparam [2:0] BLTU = 3'b110;
    localparam [2:0] BGEU = 3'b111;
    
    always @ (*) begin
    
    case (funct3) 
        BEQ : condition = (forwarded_rs1 == forwarded_rs2);
        BNE : condition = (forwarded_rs1 != forwarded_rs2);
        BLT : condition = ($signed(forwarded_rs1) < $signed(forwarded_rs2));
        BGE : condition = ($signed(forwarded_rs1) >= $signed(forwarded_rs2)) ;
        BLTU : condition = ((forwarded_rs1) < (forwarded_rs2));
        BGEU : condition = ((forwarded_rs1) >= (forwarded_rs2));
        default : condition = 1'b0;
    endcase
    
    end
    
    assign branch_taken = branch && condition && id_ex_valid_out ;
    assign branch_target = pc + immediate;
    
endmodule
