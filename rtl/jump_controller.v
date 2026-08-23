`timescale 1ns / 1ps

module jump_controller(
    input jump,
    input [31:0] pc,
    input [31:0] rs1_data,
    input [31:0] immediate,
    input [6:0] opcode,
    output reg [31:0] jump_target,
    output jump_taken,
    input id_ex_valid_out
    );
    
    assign jump_taken = jump && id_ex_valid_out;
    
    localparam JAL = 7'b1101111;
    localparam JALR = 7'b1100111;
    
    always@ (*) begin
        
        case (opcode) 
            JAL : jump_target = pc + immediate;
            
            JALR : begin
                  jump_target = rs1_data + immediate;
                  jump_target[0] = 1'b0;
            end
            
            default : jump_target = 32'b0;
            
        endcase
     end
endmodule
