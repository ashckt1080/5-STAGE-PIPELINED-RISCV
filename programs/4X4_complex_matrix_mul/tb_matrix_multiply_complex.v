`timescale 1ns / 1ps

module tb_matrix_multiply_complex;

    reg clk;
    reg rst;
    wire [3:0] debug_led;

    integer cycle_count;
    integer errors;
    integer i;
    integer j;
    integer row;
    integer col;
    integer idx;

    reg [31:0] data_memory [0:1023];

    localparam [31:0] COMPUTE_START_PC = 32'h00000214;
    localparam [31:0] HALT_PC          = 32'h000002B4;

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

        $readmemh(
            "matrix_multiply_complex.mem",
            dut.instr_mem_.memory
        );

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
        $display("INITIAL MATRIX A");
        $display("");

        for (row = 0; row < 4; row = row + 1) begin

            $write("[ ");

            for (col = 0; col < 4; col = col + 1) begin

                idx = 64 + (row * 8) + (col * 2);

                $write(
                    "%4d",
                    $signed(dut.data_mem_.memory[idx])
                );

                if ($signed(dut.data_mem_.memory[idx + 1]) >= 0)
                    $write(
                        "+%0di",
                        $signed(dut.data_mem_.memory[idx + 1])
                    );
                else
                    $write(
                        "%0di",
                        $signed(dut.data_mem_.memory[idx + 1])
                    );

                if (col != 3)
                    $write("    ");

            end

            $display(" ]");

        end

        $display("");
        $display("INITIAL MATRIX B");
        $display("");

        for (row = 0; row < 4; row = row + 1) begin

            $write("[ ");

            for (col = 0; col < 4; col = col + 1) begin

                idx = 96 + (row * 8) + (col * 2);

                $write(
                    "%4d",
                    $signed(dut.data_mem_.memory[idx])
                );

                if ($signed(dut.data_mem_.memory[idx + 1]) >= 0)
                    $write(
                        "+%0di",
                        $signed(dut.data_mem_.memory[idx + 1])
                    );
                else
                    $write(
                        "%0di",
                        $signed(dut.data_mem_.memory[idx + 1])
                    );

                if (col != 3)
                    $write("    ");

            end

            $display(" ]");

        end

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
        $display("FINAL MATRIX C");
        $display("");

        for (row = 0; row < 4; row = row + 1) begin

            $write("[ ");

            for (col = 0; col < 4; col = col + 1) begin

                idx = 128 + (row * 8) + (col * 2);

                $write(
                    "%4d",
                    $signed(dut.data_mem_.memory[idx])
                );

                if ($signed(dut.data_mem_.memory[idx + 1]) >= 0)
                    $write(
                        "+%0di",
                        $signed(dut.data_mem_.memory[idx + 1])
                    );
                else
                    $write(
                        "%0di",
                        $signed(dut.data_mem_.memory[idx + 1])
                    );

                if (col != 3)
                    $write("    ");

            end

            $display(" ]");

        end

        $display("");
        $display("Cycles = %0d", cycle_count);
        $display("Errors = %0d", errors);
        $display("");

        $finish;

    end

endmodule