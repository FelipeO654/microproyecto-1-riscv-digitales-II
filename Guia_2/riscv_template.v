module riscv (
    input clk,
    input rst,
    input [31:0] instr
);
    reg [31:0] IR;
    always @(posedge clk) begin
        if (rst) IR <= 32'b0;
        else IR <= instr;
    end

    wire [6:0] funct7 = IR[31:25];
    wire [4:0] rs2 = IR[24:20];
    wire [4:0] rs1 = IR[19:15];
    wire [2:0] funct3 = IR[14:12];
    wire [4:0] rd = IR[11:7];
    wire [6:0] opcode = IR[6:0];

    wire is_r_instr = (opcode[6:2] == 5'b01100);
    wire is_i_instr = (opcode[6:2] == 5'b00000) ||
                      (opcode[6:2] == 5'b00100) ||
                      (opcode[6:2] == 5'b11001);
    wire is_s_instr = (opcode[6:2] == 5'b01000);
    wire is_b_instr = (opcode[6:2] == 5'b11000);
    wire is_u_instr = (opcode[6:2] == 5'b00101) ||
                      (opcode[6:2] == 5'b01101);
    wire is_j_instr = (opcode[6:2] == 5'b11011);
    wire is_valid = opcode[1:0] == 2'b11;

    wire [31:0] imm =
        is_i_instr ? {{20{IR[31]}}, IR[31:20]} :
        is_s_instr ? {{20{IR[31]}}, IR[31:25], IR[11:7]} :
        is_b_instr ? {{19{IR[31]}}, IR[31], IR[7], IR[30:25], IR[11:8], 1'b0} :
        is_u_instr ? {IR[31:12], 12'b0} :
        is_j_instr ? {{11{IR[31]}}, IR[31], IR[19:12], IR[20], IR[30:21], 1'b0} :
                     32'b0;
    wire imm_valid = is_i_instr || is_s_instr || is_b_instr || is_u_instr || is_j_instr;

    wire [10:0] dec_bits = {funct7[5], funct3, opcode};
    wire is_add = (dec_bits == 11'b0_000_0110011);
    wire is_sub = (dec_bits == 11'b1_000_0110011);
    wire is_sll = (dec_bits == 11'b0_001_0110011);
    wire is_xor = (dec_bits == 11'b0_100_0110011);
    wire is_or  = (dec_bits == 11'b0_110_0110011);
    wire is_and = (dec_bits == 11'b0_111_0110011);

    wire [9:0] dec_bits2 = {funct3, opcode};
    wire is_addi = (dec_bits2 == 10'b000_0010011);
    wire is_xori = (dec_bits2 == 10'b100_0010011);
    wire is_ori  = (dec_bits2 == 10'b110_0010011);
    wire is_andi = (dec_bits2 == 10'b111_0010011);

    wire [31:0] src1_value, src2_value;
    wire [31:0] alu_a, alu_b, alu_out;
    wire [2:0] alu_op =
        (is_add || is_addi) ? 3'b000 :
        is_sub               ? 3'b001 :
        is_sll               ? 3'b010 :
        (is_xor || is_xori)  ? 3'b011 :
        (is_or || is_ori)    ? 3'b100 :
        (is_and || is_andi)  ? 3'b101 :
                              3'b000;
    wire wr_en = is_valid && (is_r_instr || is_i_instr || is_u_instr || is_j_instr);

    RegisterFile rf (
        .clk(clk), .wr_en(wr_en), .wr_index(rd), .wr_data(alu_out),
        .rd_index1(rs1), .rd_data1(src1_value),
        .rd_index2(rs2), .rd_data2(src2_value)
    );
    assign alu_a = src1_value;
    assign alu_b = imm_valid ? imm : src2_value;
    alu rv_alu (.A(alu_a), .B(alu_b), .op(alu_op), .ALU_out(alu_out));
endmodule
