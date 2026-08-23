`timescale 1ns / 1ps

module forwarding_mux(
    input forward_A_MEM,
    input forward_A_WB,
    input forward_B_MEM,
    input forward_B_WB,
    input [31:0] ex_rs1_data,
    input [31:0] ex_rs2_data,
    input [31:0] mem_ALU_out,
    input [31:0] mem_pc_plus4,
    input [1:0] mem_WB_src,
    input [31:0] wb_data,
    output reg [31:0] forwarded_data_A,
    output reg [31:0] forwarded_data_B
    );
    
    wire [31:0] forwarded_mem_data;
    assign forwarded_mem_data = (mem_WB_src == 2'b00) ? mem_ALU_out : ((mem_WB_src == 2'b10) ? mem_pc_plus4 : 32'b0);
    
    always@ (*) begin
        if(forward_A_MEM) begin
            forwarded_data_A = forwarded_mem_data;
        end
        
        else if(forward_A_WB) begin
            forwarded_data_A = wb_data;
        end
        
        else begin
            forwarded_data_A = ex_rs1_data;
        end     
    end
    
    always@ (*) begin
        if(forward_B_MEM) begin
            forwarded_data_B = forwarded_mem_data;
        end
        
        else if(forward_B_WB) begin
            forwarded_data_B = wb_data;
        end
        
        else begin
            forwarded_data_B = ex_rs2_data;
        end     
    end
    
endmodule
