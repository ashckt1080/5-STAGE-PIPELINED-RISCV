`timescale 1ns / 1ps

module cpu_bus_master (

    input request,
    input write,
    input [31:0] address,
    input [31:0] write_data,
    input [3:0] byte_sel,

    input ack,
    input err,
    input [31:0] read_data,

    output MEM_wait,
    output [31:0] load_data,
    output fault,

    output bus_request,
    output bus_write,
    output [31:0] bus_address,
    output [31:0] bus_write_data,
    output [3:0] bus_byte_sel
    
);

    assign MEM_wait = request && !(ack || err);
    assign load_data = write ? 32'b0 : read_data;
    assign fault = request && err;
    assign bus_request = request;
    assign bus_write = write;
    assign bus_address = address;
    assign bus_write_data = write_data;
    assign bus_byte_sel = byte_sel;

endmodule