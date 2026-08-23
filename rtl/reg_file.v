`timescale 1ns / 1ps

module reg_file(
    input clk, 
    input rst, 
    input write_en,
    input [4:0] rs1_addr,
    input [4:0] rs2_addr,
    input [4:0] rd_addr,
    input [31:0] wb_data,
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data,
    input mem_wb_valid_out
    );
    
    reg [31:0] memory [0:31];
    integer i;

    always @ (posedge clk) begin
        
        if(rst) begin
            for(i = 0; i < 32; i = i+1) begin
                memory[i] <= 32'b0;
            end
        end
        
        else if (write_en && mem_wb_valid_out && (rd_addr != 5'b0)) begin
            memory[rd_addr] <= wb_data;
        end
     
     end
     
    always @(*) begin
        if(rs1_addr == 5'b0) begin
            rs1_data = 32'b0;
        end
        else if(write_en && mem_wb_valid_out && (rd_addr != 5'b0) && (rd_addr == rs1_addr)) begin
            rs1_data = wb_data;
        end
        else begin
            rs1_data = memory[rs1_addr];
        end
    end

    always @(*) begin
        if(rs2_addr == 5'b0) begin
            rs2_data = 32'b0;
        end
        else if(write_en && mem_wb_valid_out && (rd_addr != 5'b0) && (rd_addr == rs2_addr)) begin
            rs2_data = wb_data;
        end
        else begin
            rs2_data = memory[rs2_addr];
        end
    end
    
endmodule
