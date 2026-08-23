module id_ex_register(
    input clk,
    input rst,
    input id_ex_enable,
    input flush,
    input valid_in,
    input [31:0] pc_in,
    input [31:0] pc_plus4_in,
    input [6:0] opcode_in,
    input [4:0] rd_addr_in,
    input [4:0] rs1_addr_in,
    input [4:0] rs2_addr_in,
    input [2:0] funct3_in,
    input [6:0] funct7_in,
    input [31:0] immediate_in,
    input [31:0] rs1_data_in,
    input [31:0] rs2_data_in,
    input [3:0] alu_op_in,
    input reg_write_in,
    input mem_write_in,
    input mem_read_in,
    input branch_in,
    input jump_in,
    input [1:0] ALU_A_src_in,
    input [1:0] ALU_B_src_in,
    input [1:0] WB_src_in,
    output reg valid_out,
    output reg [31:0] pc_out,
    output reg [31:0] pc_plus4_out,
    output reg [6:0] opcode_out,
    output reg [4:0] rd_addr_out,
    output reg [4:0] rs1_addr_out,
    output reg [4:0] rs2_addr_out,
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,
    output reg [31:0] immediate_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [3:0] alu_op_out,
    output reg reg_write_out,
    output reg mem_write_out,
    output reg mem_read_out,
    output reg branch_out,
    output reg jump_out,
    output reg [1:0] ALU_A_src_out,
    output reg [1:0] ALU_B_src_out,
    output reg [1:0] WB_src_out
);

    always @(posedge clk) begin

    if(rst) begin
        pc_out <= 32'b0;
        pc_plus4_out <= 32'b0;
        opcode_out <= 7'b0;
        rd_addr_out <= 5'b0;
        rs1_addr_out <= 5'b0;
        rs2_addr_out <= 5'b0;
        funct3_out <= 3'b0;
        funct7_out <= 7'b0;
        immediate_out <= 32'b0;
        rs1_data_out <= 32'b0;
        rs2_data_out <= 32'b0;
        alu_op_out <= 4'b0;
        reg_write_out <= 1'b0;
        mem_write_out <= 1'b0;
        mem_read_out <= 1'b0;
        branch_out <= 1'b0;
        jump_out <= 1'b0;
        ALU_A_src_out <= 2'b0;
        ALU_B_src_out <= 2'b0;
        WB_src_out <= 2'b0;
    end

    else if(id_ex_enable) begin
        pc_out <= pc_in;
        pc_plus4_out <= pc_plus4_in;
        opcode_out <= opcode_in;
        rd_addr_out <= rd_addr_in;
        rs1_addr_out <= rs1_addr_in;
        rs2_addr_out <= rs2_addr_in;
        funct3_out <= funct3_in;
        funct7_out <= funct7_in;
        immediate_out <= immediate_in;
        rs1_data_out <= rs1_data_in;
        rs2_data_out <= rs2_data_in;
        alu_op_out <= alu_op_in;
        reg_write_out <= reg_write_in;
        mem_write_out <= mem_write_in;
        mem_read_out <= mem_read_in;
        branch_out <= branch_in;
        jump_out <= jump_in;
        ALU_A_src_out <= ALU_A_src_in;
        ALU_B_src_out <= ALU_B_src_in;
        WB_src_out <= WB_src_in;
    end
    
    if (rst) begin
        valid_out <= 1'b0;
    end
    
    else if (flush) begin
        valid_out <= 1'b0;
    end
        
    else if (id_ex_enable) begin
        valid_out <= valid_in;
    end

end

endmodule