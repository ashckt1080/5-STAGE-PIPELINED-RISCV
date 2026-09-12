`timescale 1ns / 1ps

module flush_controller(
    //input branch_taken, pre branch predictor logic
    input jump_taken,
    input branch_mispredict,
    output flush
    );
    
    assign flush = branch_mispredict | jump_taken;
    
endmodule
