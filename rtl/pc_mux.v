`timescale 1ns / 1ps

module pc_mux(
    input [31:0] pc_plus4,
    input [31:0] branch_target,
    input [31:0] jump_target,
    input branch_redirect,
    input jump_redirect,
    output reg [31:0] pc_next
    );
    
    wire [1:0] pc_src = {branch_redirect, jump_redirect};
    
    always @ (*) begin
  
        case(pc_src)
            2'b00 : pc_next = pc_plus4;
            2'b01 : pc_next = jump_target;
            2'b10 : pc_next = branch_target;
            default : pc_next = pc_plus4;
        endcase
        
    end
endmodule
