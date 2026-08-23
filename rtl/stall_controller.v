`timescale 1ns / 1ps

module stall_controller(
    input ex_valid,
    input ex_mem_read,
    input [4:0] ex_rd_addr, 
    input id_valid,
    input [4:0] id_rs1_addr,
    input [4:0] id_rs2_addr, 
    input id_rs1_used,
    input id_rs2_used,
    
    output stall
    );
    
    wire rs1_stall;
    wire rs2_stall;
    
    assign rs1_stall = id_rs1_used && (id_rs1_addr == ex_rd_addr);
    assign rs2_stall = id_rs2_used && (id_rs2_addr == ex_rd_addr);
    
    assign stall = ex_valid && id_valid && ex_mem_read && (ex_rd_addr != 5'b0) && (rs1_stall || rs2_stall);
endmodule
