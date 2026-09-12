`timescale 1ns / 1ps

module pc_mux(
    input [31:0] pc_plus4,
    input [31:0] pred_target,
    input [31:0] branch_recovery,
    input [31:0] jump_target,
    input pred_redirect,
    input branch_recovery_redirect,
    input jump_redirect,
    output reg [31:0] pc_next
    );
    
    always @ (*) begin
        
        if(jump_redirect) begin
            pc_next = jump_target;
        end
        
        else if(branch_recovery_redirect) begin
            pc_next = branch_recovery;
        end
        
        else if(pred_redirect) begin
            pc_next = pred_target;
        end
        
        else begin
            pc_next = pc_plus4;
        end
        
    end
    
endmodule