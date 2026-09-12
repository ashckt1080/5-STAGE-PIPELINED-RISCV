`timescale 1ns / 1ps

module forwarding_mux(
    input forward_a_mem,
    input forward_a_wb,
    input forward_b_mem,
    input forward_b_wb,
    input [31:0] EX_rs1_data,
    input [31:0] EX_rs2_data,
    input [31:0] MEM_alu_out,
    input [31:0] MEM_pc_plus4,
    input [1:0] MEM_wb_src,
    input [31:0] WB_data,
    output reg [31:0] forwarded_data_a,
    output reg [31:0] forwarded_data_b
    );
    
    wire [31:0] forwarded_mem_data;
    assign forwarded_mem_data = (MEM_wb_src == 2'b00) ? MEM_alu_out : ((MEM_wb_src == 2'b10) ? MEM_pc_plus4 : 32'b0);
    
    always@ (*) begin
        if(forward_a_mem) begin
            forwarded_data_a = forwarded_mem_data;
        end
        
        else if(forward_a_wb) begin
            forwarded_data_a = WB_data;
        end
        
        else begin
            forwarded_data_a = EX_rs1_data;
        end     
    end
    
    always@ (*) begin
        if(forward_b_mem) begin
            forwarded_data_b = forwarded_mem_data;
        end
        
        else if(forward_b_wb) begin
            forwarded_data_b = WB_data;
        end
        
        else begin
            forwarded_data_b = EX_rs2_data;
        end     
    end
    
endmodule
