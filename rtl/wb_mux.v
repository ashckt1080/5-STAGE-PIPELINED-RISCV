`timescale 1ns / 1ps

module wb_mux(
    input [31:0] alu_result,
    input [31:0] pc_plus4,
    input [31:0] data_mem_out,
    input [1:0] WB_src,
    output reg [31:0] wb_data
    );
    
    always@ (*) begin
        case(WB_src) 
            2'b00 : wb_data = alu_result;
            2'b01 : wb_data = data_mem_out;
            2'b10 : wb_data = pc_plus4;
            default : wb_data = alu_result;
        endcase
    end
endmodule
