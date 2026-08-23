`timescale 1ns / 1ps

module tb_insertion_sort;

    reg clk;
    reg rst;
    wire [3:0] debug_led;

    integer cycle_count;
    integer errors;
    integer i;
    integer j;

    reg [31:0] data_memory [0:1023];

    localparam [31:0] SORT_START_PC = 32'h0000008C;
    localparam [31:0] HALT_PC       = 32'h000000DC;

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

        $readmemh("insertion_sort.mem", dut.instr_mem_.memory);

        for (i = 0; i < 1024; i = i + 1)
            dut.data_mem_.memory[i] = 32'b0;

        repeat (4)
            @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        wait (dut.rst == 1'b0);

        wait (
            dut.id_ex_valid_out &&
            dut.ex_pc == SORT_START_PC
        );

        @(negedge clk);

        $display("");
        $display("INITIAL ARRAY");

        for (i = 64; i < 80; i = i + 1)
            $display(
                "memory[%0d] = %08x (%0d)",
                i,
                dut.data_mem_.memory[i],
                $signed(dut.data_mem_.memory[i])
            );

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
        $display("FINAL ARRAY");

        for (i = 64; i < 80; i = i + 1)
            $display(
                "memory[%0d] = %08x (%0d)",
                i,
                dut.data_mem_.memory[i],
                $signed(dut.data_mem_.memory[i])
            );

        $display("");
        $display("Cycles = %0d", cycle_count);
        $display("Errors = %0d", errors);

        $finish;

    end

endmodule