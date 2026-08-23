`timescale 1ns / 1ps

module tb_fast_inverse_sqrt;

    reg clk;
    reg rst;
    wire [3:0] debug_led;

    integer cycle_count;
    integer errors;
    integer i;
    integer j;

    reg [31:0] data_memory [0:1023];

    localparam [31:0] COMPUTE_START_PC = 32'h00000048;
    localparam [31:0] HALT_PC          = 32'h000000B8;

    cpu_top dut (
        .clk       (clk),
        .raw_rst   (rst),
        .debug_led (debug_led)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (dut.rst)
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;
    end

    always @(negedge clk) begin
        for (j = 0; j < 1024; j = j + 1)
            data_memory[j] = dut.data_mem_.memory[j];
    end

    initial begin

        rst = 1'b1;
        cycle_count = 0;
        errors = 0;

        #1;

        $readmemh("fast_inverse_sqrt.mem", dut.instr_mem_.memory);

        for (i = 0; i < 1024; i = i + 1)
            dut.data_mem_.memory[i] = 32'b0;

        repeat (4)
            @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        wait (dut.rst == 1'b0);

        wait (
            dut.id_ex_valid_out &&
            dut.ex_pc == COMPUTE_START_PC
        );

        @(negedge clk);

        $display("");
        $display("FAST INVERSE SQUARE ROOT INPUTS");
        $display("");
        $display("x =   1.0    bits = %08x", dut.data_mem_.memory[64]);
        $display("x =   2.0    bits = %08x", dut.data_mem_.memory[65]);
        $display("x =   4.0    bits = %08x", dut.data_mem_.memory[66]);
        $display("x =   9.0    bits = %08x", dut.data_mem_.memory[67]);
        $display("x =  16.0    bits = %08x", dut.data_mem_.memory[68]);
        $display("x =  25.0    bits = %08x", dut.data_mem_.memory[69]);
        $display("x = 100.0    bits = %08x", dut.data_mem_.memory[70]);

        wait (
            dut.id_ex_valid_out &&
            dut.ex_jump &&
            dut.ex_opcode == 7'b1101111 &&
            dut.ex_pc == HALT_PC
        );

        repeat (4)
            @(posedge clk);

        @(negedge clk);

        $display("");
        $display("FAST INVERSE SQUARE ROOT RESULTS");
        $display("");
        $display("x =   1.0    result = %08x    expected ~0.9983072", dut.data_mem_.memory[80]);
        $display("x =   2.0    result = %08x    expected ~0.7069300", dut.data_mem_.memory[81]);
        $display("x =   4.0    result = %08x    expected ~0.4991536", dut.data_mem_.memory[82]);
        $display("x =   9.0    result = %08x    expected ~0.3329532", dut.data_mem_.memory[83]);
        $display("x =  16.0    result = %08x    expected ~0.2495768", dut.data_mem_.memory[84]);
        $display("x =  25.0    result = %08x    expected ~0.1996898", dut.data_mem_.memory[85]);
        $display("x = 100.0    result = %08x    expected ~0.0998449", dut.data_mem_.memory[86]);

        $display("");
        $display("Expected result bit patterns");
        $display("1.0   -> 3f7f9110");
        $display("2.0   -> 3f34f95e");
        $display("4.0   -> 3eff9110");
        $display("9.0   -> 3eaa78d9");
        $display("16.0  -> 3e7f9110");
        $display("25.0  -> 3e4c7b7a");
        $display("100.0 -> 3dcc7b7a");

        $display("");
        $display("Cycles = %0d", cycle_count);
        $display("Errors = %0d", errors);
        $display("");

        $finish;

    end

endmodule
