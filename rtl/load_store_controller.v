`timescale 1ns / 1ps

module load_store_controller(
    input MEM_valid,
    input MEM_mem_read,
    input MEM_mem_write,
    input [2:0] funct3,
    input [31:0] rs2_data,
    input [31:0] alu_addr_in,

    input [31:0] raw_read_data,
    
    output request,
    output write,
    output [31:0] address,
    output reg [31:0] write_data,
    output reg [3:0] byte_sel,
    output reg [31:0] load_result,
    output reg misaligned
    );
    
    wire memory_access = (MEM_mem_read || MEM_mem_write);
    
    assign write = MEM_mem_write;
    assign address = alu_addr_in;

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

    always@(*) begin
        write_data = 32'b0;
        byte_sel = 4'b0000;
        load_result = 32'b0;
        misaligned = 1'b0;

        if(MEM_mem_write) begin
            case(funct3)

                SB: begin
                    case(byte_index)
                        2'b00: begin byte_sel = 4'b0001; write_data = {24'b0, rs2_data[7:0]}; end
                        2'b01: begin byte_sel = 4'b0010; write_data = {16'b0, rs2_data[7:0], 8'b0}; end
                        2'b10: begin byte_sel = 4'b0100; write_data = {8'b0, rs2_data[7:0], 16'b0}; end
                        2'b11: begin byte_sel = 4'b1000; write_data = {rs2_data[7:0], 24'b0}; end
                    endcase
                end

                SH: begin
                    if(alu_addr_in[0] != 1'b0) misaligned = 1'b1;
                    else begin
                        case(half_word_index)
                            1'b0: begin byte_sel = 4'b0011; write_data = {16'b0, rs2_data[15:0]}; end
                            1'b1: begin byte_sel = 4'b1100; write_data = {rs2_data[15:0], 16'b0}; end
                        endcase
                    end
                end

                SW: begin
                    if(alu_addr_in[1:0] != 2'b00) misaligned = 1'b1;
                    else begin byte_sel = 4'b1111; write_data = rs2_data; end
                end

                default: begin byte_sel = 4'b0000; write_data = 32'b0; end
            endcase
        end

        else if(MEM_mem_read) begin
            case(funct3)

                LB: begin
                    case(byte_index)
                        2'b00: load_result = {{24{raw_read_data[7]}}, raw_read_data[7:0]};
                        2'b01: load_result = {{24{raw_read_data[15]}}, raw_read_data[15:8]};
                        2'b10: load_result = {{24{raw_read_data[23]}}, raw_read_data[23:16]};
                        2'b11: load_result = {{24{raw_read_data[31]}}, raw_read_data[31:24]};
                    endcase
                end

                LBU: begin
                    case(byte_index)
                        2'b00: load_result = {24'b0, raw_read_data[7:0]};
                        2'b01: load_result = {24'b0, raw_read_data[15:8]};
                        2'b10: load_result = {24'b0, raw_read_data[23:16]};
                        2'b11: load_result = {24'b0, raw_read_data[31:24]};
                    endcase
                end

                LH: begin
                    if(alu_addr_in[0] != 1'b0) misaligned = 1'b1;
                    else begin
                        case(half_word_index)
                            1'b0: load_result = {{16{raw_read_data[15]}}, raw_read_data[15:0]};
                            1'b1: load_result = {{16{raw_read_data[31]}}, raw_read_data[31:16]};
                        endcase
                    end
                end

                LHU: begin
                    if(alu_addr_in[0] != 1'b0) misaligned = 1'b1;
                    else begin
                        case(half_word_index)
                            1'b0: load_result = {16'b0, raw_read_data[15:0]};
                            1'b1: load_result = {16'b0, raw_read_data[31:16]};
                        endcase
                    end
                end

                LW: begin
                    if(alu_addr_in[1:0] != 2'b00) misaligned = 1'b1;
                    else load_result = raw_read_data;
                end

                default: load_result = 32'b0;
            endcase
        end
    end

    assign request = MEM_valid && memory_access && !misaligned;

endmodule