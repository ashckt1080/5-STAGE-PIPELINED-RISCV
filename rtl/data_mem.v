`timescale 1ns / 1ps

module data_mem(
    input clk,
    input mem_read,
    input mem_write,
    input [31:0] alu_addr_in,
    input [31:0] data_in,
    input [2:0] funct3,
    input valid,
    output reg [31:0] data_out
    );

    (* ram_style = "block" *)
    reg [31:0] memory [0:1023];

    reg [31:0] read_data;
    reg [2:0] read_funct3;
    reg [1:0] read_byte_index;
    reg read_valid;

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

        if(read_valid) begin

            case(read_funct3)
                LB : begin
                    case(read_byte_index)
                        2'b00 : data_out = {{24{read_data[7]}},read_data[7:0]};
                        2'b01 : data_out = {{24{read_data[15]}},read_data[15:8]};
                        2'b10 : data_out = {{24{read_data[23]}},read_data[23:16]};
                        2'b11 : data_out = {{24{read_data[31]}},read_data[31:24]};
                    endcase
                end

                LBU : begin
                    case(read_byte_index)
                        2'b00 : data_out = {24'b0,read_data[7:0]};
                        2'b01 : data_out = {24'b0,read_data[15:8]};
                        2'b10 : data_out = {24'b0,read_data[23:16]};
                        2'b11 : data_out = {24'b0,read_data[31:24]};
                    endcase
                end

                LH : begin
                    case(read_byte_index[1])
                        1'b0 : data_out = {{16{read_data[15]}},read_data[15:0]};
                        1'b1 : data_out = {{16{read_data[31]}},read_data[31:16]};
                    endcase
                end

                LHU : begin
                    case(read_byte_index[1])
                        1'b0 : data_out = {16'b0,read_data[15:0]};
                        1'b1 : data_out = {16'b0,read_data[31:16]};
                    endcase
                end

                LW : data_out = read_data;

                default : data_out = 32'b0;
            endcase
        end

        else begin
            data_out = 32'b0;
        end
    end

    always @(posedge clk) begin

        read_valid <= 1'b0;

        if(mem_read && valid) begin

            case(funct3)
                LB, LBU : begin
                    if(byte_valid) begin
                        read_data <= memory[alu_addr_in[11:2]];
                        read_funct3 <= funct3;
                        read_byte_index <= byte_index;
                        read_valid <= 1'b1;
                    end
                end

                LH, LHU : begin
                    if(half_word_valid) begin
                        read_data <= memory[alu_addr_in[11:2]];
                        read_funct3 <= funct3;
                        read_byte_index <= byte_index;
                        read_valid <= 1'b1;
                    end
                end

                LW : begin
                    if(word_valid) begin
                        read_data <= memory[alu_addr_in[11:2]];
                        read_funct3 <= funct3;
                        read_byte_index <= byte_index;
                        read_valid <= 1'b1;
                    end
                end

                default : ;
            endcase
        end

        if(mem_write && valid) begin

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
