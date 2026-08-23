`timescale 1ns / 1ps

module cpu_top(
    input clk,
    input raw_rst,
    output [3:0] debug_led
    );
    
    wire rst;
    
    reset_sync reset_sync_ (.clk(clk),
                            .raw_rst(raw_rst),
                            .rst(rst));
    
    //if signals
    wire if_pc_enable;
    wire [31:0] if_pc_next;
    wire [31:0] if_pc;
    wire [31:0] if_pc_plus4;
    wire [31:0] if_instr;
    wire if_id_valid_in;
    wire if_fetch_valid;
    wire if_id_flush;
    wire if_id_enable;
    
    //id signals
    wire [31:0] id_pc;
    wire [31:0] id_pc_plus4;
    wire [31:0] id_instr;
    wire if_id_valid_out;
    wire [6:0] id_opcode;
    wire [4:0] id_rd_addr;
    wire [4:0] id_rs1_addr;
    wire [4:0] id_rs2_addr;
    wire [2:0] id_funct3;
    wire [6:0] id_funct7;
    wire id_reg_write;
    wire id_mem_write;
    wire id_mem_read;
    wire id_branch;
    wire id_jump;
    wire [1:0] id_ALU_A_src;
    wire [1:0] id_ALU_B_src;
    wire [1:0] id_WB_src;
    wire id_opcode_invalid;
    wire [31:0] id_immediate;
    wire [3:0] id_alu_op;
    wire [31:0] id_rs1_data;
    wire [31:0] id_rs2_data;
    wire id_ex_enable;
    wire id_ex_flush;
    wire id_rs1_used;
    wire id_rs2_used;
     
    //ex signals
    wire [31:0] ex_branch_target;
    wire [31:0] ex_jump_target;
    wire ex_branch_taken;
    wire ex_jump_taken;
    wire [31:0] ex_pc;
    wire [31:0] ex_pc_plus4;
    wire [6:0] ex_opcode;
    wire [4:0] ex_rd_addr;
    wire [4:0] ex_rs1_addr;
    wire [4:0] ex_rs2_addr;
    wire [2:0] ex_funct3;
    wire [6:0] ex_funct7;
    wire ex_reg_write;
    wire ex_mem_write;
    wire ex_mem_read;
    wire ex_branch;
    wire ex_jump;
    wire [1:0] ex_ALU_A_src;
    wire [1:0] ex_ALU_B_src;
    wire [1:0] ex_WB_src;
    wire [31:0] ex_immediate;
    wire [31:0] ex_rs1_data;
    wire [31:0] ex_rs2_data;
    wire [3:0] ex_alu_op; 
    wire [31:0] ex_ALU_A_in;
    wire [31:0] ex_ALU_B_in;
    wire [31:0] ex_ALU_out;
    wire ex_Z;
    wire ex_mem_enable;
    wire ex_mem_valid_in;
    wire ex_mem_valid_out;
    wire id_ex_valid_out;
    wire id_ex_valid_in;
    
    wire [31:0] alu_m_result;
    
    //M unit
    
    wire ex_is_m_instr;
    wire ex_m_start;
    reg ex_m_started;
    wire ex_m_busy;
    wire ex_m_stall;
    wire ex_m_done;
    wire [31:0] ex_m_result;
    
    assign ex_is_m_instr = (id_ex_valid_out && ex_opcode == 7'b0110011 && ex_funct7 == 7'b0000001);
    assign ex_m_start = ex_is_m_instr && !ex_m_started && !ex_m_busy;
    assign ex_m_stall = ex_is_m_instr && !ex_m_done;
    
    //mem signals
    wire [31:0] mem_pc_plus4;
    wire [31:0] mem_ALU_out;
    wire [31:0] mem_rs1_data;
    wire [31:0] mem_rs2_data;
    wire [4:0] mem_rd_addr;
    wire [2:0] mem_funct3;
    wire mem_reg_write;
    wire mem_mem_write;
    wire mem_mem_read;
    wire [1:0] mem_WB_src;
    wire [31:0] mem_data_mem_out;
    
    
    //wb signals
    wire [31:0] wb_data;
    wire wb_reg_write;
    wire [4:0] wb_rd_addr;
    wire mem_wb_enable;
    wire mem_wb_valid_in;
    wire mem_wb_valid_out;
    wire [31:0] wb_ALU_out;
    wire [31:0] wb_data_mem;
    wire [31:0] wb_pc_plus4;
    wire [1:0] wb_WB_src;
    
    //hazrad signals
    //wire [1:0] forward_sel_A;
    //wire [1:0] forward_sel_B;
    
    wire forward_A_MEM;
    wire forward_A_WB;
    wire forward_B_MEM;
    wire forward_B_WB;
    wire [31:0] forwarded_rs1_data;
    wire [31:0] forwarded_rs2_data;
    
    wire stall;
    wire flush;
    
    wire ex_branch_redirect;
    wire ex_jump_redirect;
    wire ex_instr_addr_aligned;
    
    wire ex_instr_addr_fault;
    
    assign ex_instr_addr_fault = id_ex_valid_out && !ex_instr_addr_aligned;
    
    assign ex_branch_redirect = ex_branch_taken && ex_instr_addr_aligned;
    assign ex_jump_redirect = ex_jump_taken && ex_instr_addr_aligned;
    
    assign if_pc_plus4 = if_pc + 32'd4;
    assign if_pc_enable = flush ? 1'b1 : ((stall | ex_m_stall) ? 1'b0 : 1'b1);
    
    assign if_id_valid_in = if_fetch_valid;
    assign if_id_flush = flush | ex_instr_addr_fault ;
    assign if_id_enable = (stall | ex_m_stall) ? 1'b0 : 1'b1;
    
    assign id_ex_valid_in = stall ? 1'b0 : if_id_valid_out;
    assign id_ex_flush = flush | ex_instr_addr_fault;
    assign id_ex_enable = ex_m_stall ? 1'b0 : 1'b1; 
    
    assign ex_mem_valid_in = ex_m_stall ? 1'b0 : id_ex_valid_out;
    assign ex_mem_enable = 1'b1;
    
    assign mem_wb_valid_in = ex_mem_valid_out; 
    assign mem_wb_enable = 1'b1;

    always @(posedge clk) begin
        if(rst) begin
            ex_m_started <= 1'b0;
        end
        
        else if(ex_m_done) begin
            ex_m_started <= 1'b0;
        end
        
        else if(ex_m_start) begin
            ex_m_started <= 1'b1;
        end
    end
    
    pc pc_ (.clk(clk),
            .rst(rst),
            .pc_enable(if_pc_enable),
            .pc_next(if_pc_next),
            .pc(if_pc));
    
    pc_mux pc_mux_ (.pc_plus4(if_pc_plus4),
                    .branch_target(ex_branch_target),
                    .jump_target(ex_jump_target),
                    .branch_redirect(ex_branch_redirect),
                    .jump_redirect(ex_jump_redirect),
                    .pc_next(if_pc_next));
            
    instr_mem instr_mem_ (.pc_in(if_pc),
                          .instr_out(if_instr),
                          .fetch_valid(if_fetch_valid));
    
                          
    if_id_register if_id_register_ (.clk(clk),
                                    .rst(rst),
                                    .if_id_enable(if_id_enable), 
                                    .flush(if_id_flush), 
                                    .valid_in(if_id_valid_in),
                                    .instr_in(if_instr),
                                    .pc_in(if_pc),
                                    .pc_plus4_in(if_pc_plus4),
                                    .instr_out(id_instr),
                                    .pc_out(id_pc),
                                    .pc_plus4_out(id_pc_plus4),
                                    .valid_out(if_id_valid_out));
                                    
    instr_field_extractor instr_field_extractor_ (.instr(id_instr),
                                                  .opcode(id_opcode),
                                                  .rd_addr(id_rd_addr),
                                                  .rs1_addr(id_rs1_addr),
                                                  .rs2_addr(id_rs2_addr),
                                                  .funct3(id_funct3),
                                                  .funct7(id_funct7));
    
    decoder decoder_ (.opcode(id_opcode),
                      .reg_write(id_reg_write),
                      .mem_write(id_mem_write),
                      .mem_read(id_mem_read),
                      .ALU_A_src(id_ALU_A_src),
                      .ALU_B_src(id_ALU_B_src),
                      .WB_src(id_WB_src),
                      .opcode_invalid(id_opcode_invalid),
                      .branch(id_branch),
                      .jump(id_jump),
                      .rs1_used(id_rs1_used),
                      .rs2_used(id_rs2_used));
                      
    imm_gen imm_gen_ (.instr(id_instr),
                      .immediate(id_immediate));
                      
    alu_decoder alu_decoder_ (.instr(id_instr),
                              .alu_op(id_alu_op));    
    
    reg_file reg_file_ (.clk(clk),
                        .rst(rst),
                        .write_en(wb_reg_write),
                        .rs1_addr(id_rs1_addr),
                        .rs2_addr(id_rs2_addr),
                        .rd_addr(wb_rd_addr),
                        .rs1_data(id_rs1_data),
                        .rs2_data(id_rs2_data),
                        .wb_data(wb_data),
                        .mem_wb_valid_out(mem_wb_valid_out));
                        
    id_ex_register id_ex_register_ (.clk(clk),
                                    .rst(rst),
                                    .id_ex_enable(id_ex_enable), 
                                    .flush(id_ex_flush),
                                    .valid_in(id_ex_valid_in),
                                    .pc_in(id_pc),
                                    .pc_plus4_in(id_pc_plus4),
                                    .opcode_in(id_opcode),
                                    .rd_addr_in(id_rd_addr),
                                    .rs1_addr_in(id_rs1_addr),
                                    .rs2_addr_in(id_rs2_addr),
                                    .funct3_in(id_funct3),
                                    .funct7_in(id_funct7),
                                    .immediate_in(id_immediate),
                                    .rs1_data_in(id_rs1_data),
                                    .rs2_data_in(id_rs2_data),
                                    .alu_op_in(id_alu_op),
                                    .reg_write_in(id_reg_write),
                                    .mem_write_in(id_mem_write),
                                    .mem_read_in(id_mem_read),
                                    .branch_in(id_branch),
                                    .jump_in(id_jump),
                                    .ALU_A_src_in(id_ALU_A_src),
                                    .ALU_B_src_in(id_ALU_B_src),
                                    .WB_src_in(id_WB_src),
                                    .valid_out(id_ex_valid_out),
                                    .pc_out(ex_pc),
                                    .pc_plus4_out(ex_pc_plus4),
                                    .opcode_out(ex_opcode),
                                    .rd_addr_out(ex_rd_addr),
                                    .rs1_addr_out(ex_rs1_addr),
                                    .rs2_addr_out(ex_rs2_addr),
                                    .funct3_out(ex_funct3),
                                    .funct7_out(ex_funct7),
                                    .immediate_out(ex_immediate),
                                    .rs1_data_out(ex_rs1_data),
                                    .rs2_data_out(ex_rs2_data),
                                    .alu_op_out(ex_alu_op),
                                    .reg_write_out(ex_reg_write),
                                    .mem_write_out(ex_mem_write),
                                    .mem_read_out(ex_mem_read),
                                    .branch_out(ex_branch),
                                    .jump_out(ex_jump),
                                    .ALU_A_src_out(ex_ALU_A_src),
                                    .ALU_B_src_out(ex_ALU_B_src),
                                    .WB_src_out(ex_WB_src));  
                                    
    alu_mux alu_mux_ (.rs1_data(forwarded_rs1_data), //forwarded
                      .rs2_data(forwarded_rs2_data), //forwarded
                      .pc(ex_pc),
                      .immediate(ex_immediate),
                      .ALU_A_src(ex_ALU_A_src),                                                   
                      .ALU_B_src(ex_ALU_B_src),
                      .ALU_A_out(ex_ALU_A_in),                                                      
                      .ALU_B_out(ex_ALU_B_in));
                      
    alu alu_ (.A(ex_ALU_A_in),
              .B(ex_ALU_B_in),
              .opcode(ex_alu_op),
              .result(ex_ALU_out),
              .Z(ex_Z));
              
    branch_controller branch_controller_ (.pc(ex_pc),
                                          .immediate(ex_immediate),
                                          .funct3(ex_funct3),
                                          .forwarded_rs1(forwarded_rs1_data), //forwarded
                                          .forwarded_rs2(forwarded_rs2_data), //forwarded
                                          .branch(ex_branch),
                                          .branch_target(ex_branch_target),
                                          .branch_taken(ex_branch_taken),
                                          .id_ex_valid_out(id_ex_valid_out));
                                       
    jump_controller jump_controller_ (.pc(ex_pc),
                                      .immediate(ex_immediate),
                                      .opcode(ex_opcode),
                                      .jump(ex_jump),
                                      .rs1_data(forwarded_rs1_data), //forwarded
                                      .jump_target(ex_jump_target),
                                      .jump_taken(ex_jump_taken),
                                      .id_ex_valid_out(id_ex_valid_out));
                                      
                                      
    ex_mem_register ex_mem_register_ (.clk(clk),
                                      .rst(rst),
                                      .ex_mem_enable(ex_mem_enable),
                                      .valid_in(ex_mem_valid_in),
                                      .pc_plus4_in(ex_pc_plus4),
                                      .alu_result_in(alu_m_result),
                                      .rs1_data_in(forwarded_rs1_data), //forwarded
                                      .rs2_data_in(forwarded_rs2_data), //forwarded
                                      .rd_addr_in(ex_rd_addr),
                                      .funct3_in(ex_funct3),
                                      .reg_write_in(ex_reg_write),
                                      .mem_write_in(ex_mem_write),
                                      .mem_read_in(ex_mem_read),
                                      .WB_src_in(ex_WB_src),
                                      .valid_out(ex_mem_valid_out),
                                      .pc_plus4_out(mem_pc_plus4),
                                      .alu_result_out(mem_ALU_out),
                                      .rs1_data_out(mem_rs1_data),
                                      .rs2_data_out(mem_rs2_data),
                                      .rd_addr_out(mem_rd_addr),
                                      .funct3_out(mem_funct3),
                                      .reg_write_out(mem_reg_write),
                                      .mem_read_out(mem_mem_read),
                                      .mem_write_out(mem_mem_write),
                                      .WB_src_out(mem_WB_src));
                                      
    data_mem data_mem_ (.clk(clk),
                        .rst(rst),
                        .mem_read(mem_mem_read),
                        .mem_write(mem_mem_write),
                        .alu_addr_in(mem_ALU_out),
                        .data_in(mem_rs2_data),
                        .funct3(mem_funct3),
                        .data_out(mem_data_mem_out),
                        .ex_mem_valid_out(ex_mem_valid_out));

    mem_wb_register mem_wb_register_ (.clk(clk),
                                      .rst(rst),
                                      .mem_wb_enable(mem_wb_enable),
                                      .valid_in(mem_wb_valid_in),
                                      .alu_result_in(mem_ALU_out),
                                      .data_mem_in(mem_data_mem_out),
                                      .pc_plus4_in(mem_pc_plus4),
                                      .rd_addr_in(mem_rd_addr),
                                      .reg_write_in(mem_reg_write),
                                      .WB_src_in(mem_WB_src),
                                      .valid_out(mem_wb_valid_out),
                                      .alu_result_out(wb_ALU_out),
                                      .data_mem_out(wb_data_mem),
                                      .pc_plus4_out(wb_pc_plus4),
                                      .rd_addr_out(wb_rd_addr),
                                      .reg_write_out(wb_reg_write),
                                      .WB_src_out(wb_WB_src));  

    wb_mux wb_mux_ (.alu_result(wb_ALU_out),
                    .pc_plus4(wb_pc_plus4),
                    .data_mem_out(wb_data_mem),
                    .WB_src(wb_WB_src),
                    .wb_data(wb_data));                 
                    
    forwarding_controller forwarding_controller_ (.ex_rs1_addr(ex_rs1_addr),
                                                  .ex_rs2_addr(ex_rs2_addr),
                                                  .ex_mem_valid_out(ex_mem_valid_out),
                                                  .mem_rd_addr(mem_rd_addr),
                                                  .mem_reg_write(mem_reg_write),
                                                  .mem_mem_read(mem_mem_read),
                                                  .wb_rd_addr(wb_rd_addr),
                                                  .wb_reg_write(wb_reg_write),
                                                  .mem_wb_valid_out(mem_wb_valid_out),
                                                  .forward_A_MEM(forward_A_MEM),
                                                  .forward_A_WB(forward_A_WB),
                                                  .forward_B_MEM(forward_B_MEM),
                                                  .forward_B_WB(forward_B_WB)
                                                  ); 
                                                  
    forwarding_mux forwarding_mux_ (.forward_A_MEM(forward_A_MEM),
                                    .forward_A_WB(forward_A_WB),
                                    .forward_B_MEM(forward_B_MEM),
                                    .forward_B_WB(forward_B_WB),
                                    .ex_rs1_data(ex_rs1_data),
                                    .ex_rs2_data(ex_rs2_data),
                                    .mem_ALU_out(mem_ALU_out),
                                    .mem_pc_plus4(mem_pc_plus4),
                                    .mem_WB_src(mem_WB_src),
                                    .wb_data(wb_data),
                                    .forwarded_data_A(forwarded_rs1_data), //forwarded
                                    .forwarded_data_B(forwarded_rs2_data)); //forwarded
                                    
    stall_controller stall_controller_ (.ex_valid(id_ex_valid_out),
                                        .ex_mem_read(ex_mem_read),
                                        .ex_rd_addr(ex_rd_addr),
                                        .id_valid(if_id_valid_out),
                                        .id_rs1_addr(id_rs1_addr),
                                        .id_rs2_addr(id_rs2_addr),
                                        .id_rs1_used(id_rs1_used),
                                        .id_rs2_used(id_rs2_used),
                                        .stall(stall));           
                                        
    flush_controller flush_controller_ (.branch_taken(ex_branch_taken),
                                        .jump_taken(ex_jump_taken),
                                        .flush(flush));
    
    instr_addr_alignment instr_addr_alignment_ (.branch_taken(ex_branch_taken),
                                                .jump_taken(ex_jump_taken),
                                                .branch_target(ex_branch_target),
                                                .jump_target(ex_jump_target),
                                                .instr_addr_aligned(ex_instr_addr_aligned));
                                                
    m_unit m_unit_ (.clk(clk),
                    .rst(rst),
                    .start(ex_m_start),
                    .A_in(forwarded_rs1_data),
                    .B_in(forwarded_rs2_data),
                    .funct3(ex_funct3),
                    .result(ex_m_result),
                    .done(ex_m_done),
                    .busy(ex_m_busy));
                    
    alu_m_result_mux alu_m_result_mux_ (.ex_ALU_out(ex_ALU_out),
                                        .ex_m_result(ex_m_result),
                                        .ex_is_m_instr(ex_is_m_instr),
                                        .alu_m_result(alu_m_result));
    
    assign debug_led[0] = ^if_pc;
    assign debug_led[1] = ^if_instr;
    assign debug_led[2] = ^wb_data;
    assign debug_led[3] = ^mem_data_mem_out;
                                        
                                                             
endmodule
