`timescale 1ns / 1ps

module data_mem(
    input clk,
    input rst,
    input mem_read,
    input mem_write,
    input [31:0] alu_addr_in,
    input [31:0] data_in,
    input [2:0] funct3,
    input ex_mem_valid_out,
    output reg [31:0] data_out
    );

    (* ram_style = "distributed" *)
    reg [31:0] memory [0:1023];

    wire addr_valid;
    wire word_valid;
    wire half_word_valid;
    wire byte_valid;

    wire [1:0] byte_index;
    wire half_word_index;

    assign byte_index = alu_addr_in[1:0];
    assign half_word_index = alu_addr_in[1];

    localparam [2:0] LB = 3'b000;
    localparam [2:0] LH = 3'b001;
    localparam [2:0] LW = 3'b010;
    localparam [2:0] LBU = 3'b100;
    localparam [2:0] LHU = 3'b101;

    localparam [2:0] SB = 3'b000;
    localparam [2:0] SH = 3'b001;
    localparam [2:0] SW = 3'b010;

    assign addr_valid = (alu_addr_in < 32'd4096);
    assign word_valid = addr_valid && (alu_addr_in[1:0] == 2'b00);
    assign half_word_valid = addr_valid && (alu_addr_in[0] == 1'b0);
    assign byte_valid = addr_valid;

    always @(*) begin

        case(funct3)
            LB : begin
                case(byte_index)
                    2'b00 : data_out = (byte_valid && mem_read && ex_mem_valid_out) ? {{24{memory[alu_addr_in[11:2]][7]}},memory[alu_addr_in[11:2]][7:0]} : 32'b0;
                    2'b01 : data_out = (byte_valid && mem_read && ex_mem_valid_out) ? {{24{memory[alu_addr_in[11:2]][15]}},memory[alu_addr_in[11:2]][15:8]} : 32'b0;
                    2'b10 : data_out = (byte_valid && mem_read && ex_mem_valid_out) ? {{24{memory[alu_addr_in[11:2]][23]}},memory[alu_addr_in[11:2]][23:16]} : 32'b0;
                    2'b11 : data_out = (byte_valid && mem_read && ex_mem_valid_out) ? {{24{memory[alu_addr_in[11:2]][31]}},memory[alu_addr_in[11:2]][31:24]} : 32'b0;
                endcase
            end

            LBU : begin
                case(byte_index)
                    2'b00 : data_out = (byte_valid && mem_read && ex_mem_valid_out) ? {24'b0,memory[alu_addr_in[11:2]][7:0]} : 32'b0;
                    2'b01 : data_out = (byte_valid && mem_read && ex_mem_valid_out) ? {24'b0,memory[alu_addr_in[11:2]][15:8]} : 32'b0;
                    2'b10 : data_out = (byte_valid && mem_read && ex_mem_valid_out) ? {24'b0,memory[alu_addr_in[11:2]][23:16]} : 32'b0;
                    2'b11 : data_out = (byte_valid && mem_read && ex_mem_valid_out) ? {24'b0,memory[alu_addr_in[11:2]][31:24]} : 32'b0;
                endcase
            end

            LH : begin
                case(half_word_index)
                    1'b0 : data_out = (half_word_valid && mem_read && ex_mem_valid_out) ? {{16{memory[alu_addr_in[11:2]][15]}},memory[alu_addr_in[11:2]][15:0]} : 32'b0;
                    1'b1 : data_out = (half_word_valid && mem_read && ex_mem_valid_out) ? {{16{memory[alu_addr_in[11:2]][31]}},memory[alu_addr_in[11:2]][31:16]} : 32'b0;
                endcase
            end

            LHU : begin
                case(half_word_index)
                    1'b0 : data_out = (half_word_valid && mem_read && ex_mem_valid_out) ? {16'b0,memory[alu_addr_in[11:2]][15:0]} : 32'b0;
                    1'b1 : data_out = (half_word_valid && mem_read && ex_mem_valid_out) ? {16'b0,memory[alu_addr_in[11:2]][31:16]} : 32'b0;
                endcase
            end

            LW : data_out = (word_valid && mem_read && ex_mem_valid_out) ? memory[alu_addr_in[11:2]] : 32'b0;

            default : data_out = 32'b0;
        endcase
    end

    always @(posedge clk) begin
    
        if(mem_write && ex_mem_valid_out) begin

            case(funct3)
                SB : begin
                    if(byte_valid) begin
                        case(byte_index)
                            2'b00 : memory[alu_addr_in[11:2]][7:0] <= data_in[7:0];
                            2'b01 : memory[alu_addr_in[11:2]][15:8] <= data_in[7:0];
                            2'b10 : memory[alu_addr_in[11:2]][23:16] <= data_in[7:0];
                            2'b11 : memory[alu_addr_in[11:2]][31:24] <= data_in[7:0];
                        endcase
                    end
                end

                SH : begin
                    if(half_word_valid) begin
                        case(half_word_index)
                            1'b0 : memory[alu_addr_in[11:2]][15:0] <= data_in[15:0];
                            1'b1 : memory[alu_addr_in[11:2]][31:16] <= data_in[15:0];
                        endcase
                    end
                end

                SW : begin
                    if(word_valid)
                        memory[alu_addr_in[11:2]] <= data_in;
                end

                default : ;
            endcase
        end
    end

endmodule