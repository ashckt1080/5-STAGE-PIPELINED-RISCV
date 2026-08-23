`timescale 1ns / 1ps

module ex_mem_register(
    input clk,
    input rst,
    input ex_mem_enable,
    input valid_in,
    input [31:0] pc_plus4_in,
    input [31:0] alu_result_in,
    input [31:0] rs1_data_in,
    input [31:0] rs2_data_in,
    input [4:0] rd_addr_in,
    input [2:0] funct3_in,
    input reg_write_in,
    input mem_read_in,
    input mem_write_in,
    input [1:0] WB_src_in,
    output reg valid_out,
    output reg [31:0] pc_plus4_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [4:0] rd_addr_out,
    output reg [2:0] funct3_out,
    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg [1:0] WB_src_out
);

    always @(posedge clk) begin
        if(rst) begin
            valid_out <= 1'b0;
            pc_plus4_out <= 32'b0;
            alu_result_out <= 32'b0;
            rs1_data_out <= 32'b0;
            rs2_data_out <= 32'b0;
            rd_addr_out <= 5'b0;
            funct3_out <= 3'b0;
            reg_write_out <= 1'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            WB_src_out <= 2'b0;
        end
        else if(ex_mem_enable) begin
            valid_out <= valid_in;
            pc_plus4_out <= pc_plus4_in;
            alu_result_out <= alu_result_in;
            rs1_data_out <= rs1_data_in;
            rs2_data_out <= rs2_data_in;
            rd_addr_out <= rd_addr_in;
            funct3_out <= funct3_in;
            reg_write_out <= reg_write_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            WB_src_out <= WB_src_in;
        end
    end

endmodule
