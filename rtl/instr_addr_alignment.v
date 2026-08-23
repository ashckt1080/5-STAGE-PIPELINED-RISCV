`timescale 1ns / 1ps

module instr_addr_alignment(
    input branch_taken,
    input jump_taken,
    input [31:0] branch_target,
    input [31:0] jump_target,
    output reg instr_addr_aligned
    );
    
    wire branch_misaligned;
    wire jump_misaligned;
    
    assign branch_misaligned = (branch_target[1:0] != 2'b00);
    assign jump_misaligned = (jump_target[1:0] != 2'b00);
    
    always@ (*) begin
        if(branch_taken && branch_misaligned) begin
            instr_addr_aligned = 1'b0;
        end
        
        else if(jump_taken && jump_misaligned) begin
            instr_addr_aligned = 1'b0;
        end
        
        else begin
            instr_addr_aligned = 1'b1;
        end
    end
    
endmodule