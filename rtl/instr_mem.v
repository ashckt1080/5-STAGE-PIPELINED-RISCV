`timescale 1ns / 1ps

module instr_mem(
    input clk,
    input read_en,
    input [31:0] pc_in,
    output reg [31:0] instr_out
    );

    (* rom_style = "block" *)
    reg [31:0] memory [0:1023];

    initial begin
        $readmemh("program.mem", memory);
    end

    always @(posedge clk) begin
        if(read_en) begin
            instr_out <= memory[pc_in[11:2]];
        end
    end

endmodule
