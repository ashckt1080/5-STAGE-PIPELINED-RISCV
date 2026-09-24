`timescale 1ns / 1ps

module pc(
    input clk,
    input rst,
    input [31:0] pc_next,
    output [31:0] pc
    );

    (* extract_enable = "no" *)
    reg [31:0] pc_reg;

    assign pc = pc_reg;

    always @(posedge clk) begin
        if(rst)
            pc_reg <= 32'b0;

        else
            pc_reg <= pc_next;
    end

endmodule
