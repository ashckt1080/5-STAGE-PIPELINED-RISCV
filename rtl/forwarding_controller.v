`timescale 1ns / 1ps

module forwarding_controller(
    input [4:0] EX_rs1_addr,
    input [4:0] EX_rs2_addr,
    input MEM_valid,
    input [4:0] MEM_rd_addr,
    input MEM_reg_write,
    input MEM_mem_read,
    input [4:0] WB_rd_addr,
    input WB_reg_write,
    input WB_valid,
    output forward_a_mem,
    output forward_a_wb,
    output forward_b_mem,
    output forward_b_wb
    );
    
    localparam [1:0] ORIGINAL = 2'b00;
    localparam [1:0] MEM = 2'b01;
    localparam [1:0] WB = 2'b10;
    
    assign forward_a_mem = (MEM_valid) && (MEM_reg_write) && !(MEM_rd_addr == 5'b0) && !(MEM_mem_read) && (MEM_rd_addr == EX_rs1_addr);
    assign forward_a_wb = (WB_valid) && (WB_reg_write) && !(WB_rd_addr == 5'b0) && (WB_rd_addr == EX_rs1_addr);
    
    assign forward_b_mem = (MEM_valid) && (MEM_reg_write) && !(MEM_rd_addr == 5'b0) && !(MEM_mem_read) && (MEM_rd_addr == EX_rs2_addr);
    assign forward_b_wb = (WB_valid) && (WB_reg_write) && !(WB_rd_addr == 5'b0) && (WB_rd_addr == EX_rs2_addr);
    
endmodule
