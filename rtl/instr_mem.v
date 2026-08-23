`timescale 1ns / 1ps

module instr_mem(
    input  [31:0] pc_in,
    output [31:0] instr_out,
    output fetch_valid
    );

    (* rom_style = "distributed" *)
    reg [31:0] memory [0:1023];

    wire flag_instr_aligned;
    wire flag_instr_valid;

    initial begin
        $readmemh("program.mem", memory);
    end

    assign flag_instr_aligned = (pc_in[1:0] == 2'b00);
    assign flag_instr_valid = (pc_in[31:12] == 20'b0);

    assign instr_out = (flag_instr_aligned && flag_instr_valid) ? memory[pc_in[11:2]] : 32'b0;

    assign fetch_valid = flag_instr_aligned && flag_instr_valid;

endmodule