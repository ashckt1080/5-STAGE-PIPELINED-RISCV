`timescale 1ns / 1ps

module stall_controller(
    input EX_valid,
    input EX_mem_read,
    input [4:0] EX_rd_addr,
    input ID_valid,
    input [4:0] ID_rs1_addr,
    input [4:0] ID_rs2_addr,
    input ID_rs1_used,
    input ID_rs2_used,
    
    output stall
    );
    
    wire rs1_stall;
    wire rs2_stall;
    
    assign rs1_stall = ID_rs1_used && (ID_rs1_addr == EX_rd_addr);
    assign rs2_stall = ID_rs2_used && (ID_rs2_addr == EX_rd_addr);
    
    assign stall = EX_valid && ID_valid && EX_mem_read && (EX_rd_addr != 5'b0) && (rs1_stall || rs2_stall);
endmodule
