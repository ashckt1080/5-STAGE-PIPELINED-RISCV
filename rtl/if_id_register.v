`timescale 1ns / 1ps

module if_id_register(
    input clk,
    input rst,
    input if_id_enable,
    input flush,
    input valid_in,
    input [31:0] instr_in,
    input [31:0] pc_in,
    input [31:0] pc_plus4_in,
    input spec_taken_in,
    input [5:0] pred_index_in,
    output reg [31:0] instr_out,
    output reg [31:0] pc_out,
    output reg [31:0] pc_plus4_out,
    output reg valid_out,
    output reg spec_taken_out,
    output reg [5:0] pred_index_out
    );
    
    always @(posedge clk) begin
        if(rst) begin
            instr_out <= 32'b0;
            pc_out <= 32'b0;
            pc_plus4_out <= 32'b0;
            spec_taken_out <= 1'b0;
            pred_index_out <= 6'b0;
        end
        
        else if (if_id_enable) begin    
            instr_out <= instr_in;
            pc_out <= pc_in;
            pc_plus4_out <= pc_plus4_in;
            spec_taken_out <= spec_taken_in;
            pred_index_out <= pred_index_in;
        end
        
        if (rst) begin
            valid_out <= 1'b0;
        end
        
        else if (flush) begin
            valid_out <= 1'b0;
        end
        
        else if (if_id_enable) begin
            valid_out <= valid_in;
        end
        
    end 
endmodule
