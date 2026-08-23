`timescale 1ns / 1ps

module mem_wb_register(
    input clk,
    input rst,
    input mem_wb_enable,
    input valid_in,
    input [31:0] alu_result_in,
    input [31:0] data_mem_in,
    input [31:0] pc_plus4_in,
    input [4:0] rd_addr_in,
    input reg_write_in,
    input [1:0] WB_src_in,
    output reg valid_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] data_mem_out,
    output reg [31:0] pc_plus4_out,
    output reg [4:0] rd_addr_out,
    output reg reg_write_out,
    output reg [1:0] WB_src_out
);

    always @(posedge clk) begin
        if(rst) begin
            valid_out <= 1'b0;
            alu_result_out <= 32'b0;
            data_mem_out <= 32'b0;
            pc_plus4_out <= 32'b0;
            rd_addr_out <= 5'b0;
            reg_write_out <= 1'b0;
            WB_src_out <= 2'b0;
        end
        else if(mem_wb_enable) begin
            valid_out <= valid_in;
            alu_result_out <= alu_result_in;
            data_mem_out <= data_mem_in;
            pc_plus4_out <= pc_plus4_in;
            rd_addr_out <= rd_addr_in;
            reg_write_out <= reg_write_in;
            WB_src_out <= WB_src_in;
        end
    end

endmodule