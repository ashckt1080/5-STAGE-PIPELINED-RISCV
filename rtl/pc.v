`timescale 1ns / 1ps

module pc(
    input clk,
    input rst,
    input pc_enable,
    input [31:0] pc_next,
    output reg [31:0] pc
    );
    
    
    always @ (posedge clk) begin
        if(rst) begin
            pc <= 32'b0;
        end
     
        else begin
            if(pc_enable) begin
                pc <= pc_next;
            end
        end
    end
    
endmodule