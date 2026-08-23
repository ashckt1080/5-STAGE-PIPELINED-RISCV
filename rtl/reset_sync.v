`timescale 1ns / 1ps

module reset_sync (
    input clk,
    input raw_rst,
    output rst
    );

    (* ASYNC_REG = "TRUE" *) reg sync_ff1 = 1'b1;
    (* ASYNC_REG = "TRUE" *) reg sync_ff2 = 1'b1;

    always @ (posedge clk) begin
        sync_ff1 <= raw_rst;
        sync_ff2 <= sync_ff1;
    end

    assign rst = sync_ff2;

endmodule