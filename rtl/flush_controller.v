`timescale 1ns / 1ps

module flush_controller(
    input branch_taken,
    input jump_taken,
    output flush
    );
    
    assign flush = branch_taken | jump_taken;
    
endmodule
