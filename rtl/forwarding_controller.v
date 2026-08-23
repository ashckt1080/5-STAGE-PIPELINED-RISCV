`timescale 1ns / 1ps

module forwarding_controller(
    input [4:0] ex_rs1_addr,
    input [4:0] ex_rs2_addr,
    input ex_mem_valid_out,
    input [4:0] mem_rd_addr,
    input mem_reg_write,
    input mem_mem_read, 
    input [4:0] wb_rd_addr,
    input wb_reg_write,
    input mem_wb_valid_out,
    output forward_A_MEM,
    output forward_A_WB,
    output forward_B_MEM,
    output forward_B_WB
    );
    
    localparam [1:0] ORIGINAL = 2'b00;
    localparam [1:0] MEM = 2'b01;
    localparam [1:0] WB = 2'b10;
    
    assign forward_A_MEM = (ex_mem_valid_out) && (mem_reg_write) && !(mem_rd_addr == 5'b0) && !(mem_mem_read) && (mem_rd_addr == ex_rs1_addr);
    assign forward_A_WB = (mem_wb_valid_out) && (wb_reg_write) && !(wb_rd_addr == 5'b0) && (wb_rd_addr == ex_rs1_addr);
    
    assign forward_B_MEM = (ex_mem_valid_out) && (mem_reg_write) && !(mem_rd_addr == 5'b0) && !(mem_mem_read) && (mem_rd_addr == ex_rs2_addr);
    assign forward_B_WB = (mem_wb_valid_out) && (wb_reg_write) && !(wb_rd_addr == 5'b0) && (wb_rd_addr == ex_rs2_addr);
    
endmodule
