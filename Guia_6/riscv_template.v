module riscv (
    input clk,
    input rst,
    input [31:0] instr,
    output [31:0] iaddr,
    output [31:0] daddr,
    input  [31:0] ddata_in,
    output [31:0] ddata_out,
    output dwr_en,
    output drd_en
);

    // PC y cuatro etapas del ciclo de instruccion
    reg [31:0] pc;
    reg state_fetch, state_decode, state_execute, state_execute2;
    reg [31:0] IR;
    reg [31:0] instr_pc;  // PC de la instruccion en IR
    reg [31:0] pc_plus_4; // Direccion de retorno estable

    assign iaddr = pc;

    always @(negedge clk) begin
        if (rst) begin
            state_fetch    <= 1'b1;
            state_decode   <= 1'b0;
            state_execute  <= 1'b0;
            state_execute2 <= 1'b0;
        end else begin
            state_fetch    <= state_execute2;
            state_decode   <= state_fetch;
            state_execute  <= state_decode;
            state_execute2 <= state_execute;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            IR <= 32'b0;
            instr_pc <= 32'b0;
        end else if (state_fetch) begin
            IR <= instr;
            instr_pc <= pc;
        end
    end

    // Guardar PC+4 antes de cambiar el contador del programa
    always @(posedge clk) begin
        if (rst) pc_plus_4 <= 32'b0;
        else if (state_decode) pc_plus_4 <= instr_pc + 32'd4;
    end

    // Campos de instruccion
    wire [6:0] funct7 = IR[31:25];
    wire [4:0] rs2    = IR[24:20];
    wire [4:0] rs1    = IR[19:15];
    wire [2:0] funct3 = IR[14:12];
    wire [4:0] rd     = IR[11:7];
    wire [6:0] opcode = IR[6:0];

    wire is_r_instr = (opcode == 7'b0110011);
    wire is_i_instr = (opcode == 7'b0000011) ||
                      (opcode == 7'b0010011) ||
                      (opcode == 7'b1100111);
    wire is_s_instr = (opcode == 7'b0100011);
    wire is_b_instr = (opcode == 7'b1100011);
    wire is_u_instr = (opcode == 7'b0010111) ||
                      (opcode == 7'b0110111);
    wire is_j_instr = (opcode == 7'b1101111);
    wire is_jal = is_j_instr;
    wire is_jalr = (opcode == 7'b1100111) && (funct3 == 3'b000);
    wire is_valid   = (opcode[1:0] == 2'b11) &&
                      (is_r_instr || is_i_instr || is_s_instr ||
                       is_b_instr || is_u_instr || is_j_instr);

    // Generador de inmediatos (Guia 2)
    wire [31:0] imm =
        is_i_instr ? {{20{IR[31]}}, IR[31:20]} :
        is_s_instr ? {{20{IR[31]}}, IR[31:25], IR[11:7]} :
        is_b_instr ? {{19{IR[31]}}, IR[31], IR[7], IR[30:25], IR[11:8], 1'b0} :
        is_u_instr ? {IR[31:12], 12'b0} :
        is_j_instr ? {{11{IR[31]}}, IR[31], IR[19:12], IR[20], IR[30:21], 1'b0} :
                     32'b0;

    wire imm_valid = is_i_instr || is_s_instr || is_b_instr ||
                     is_u_instr || is_j_instr;

    // Instrucciones de las guias anteriores
    wire is_add  = is_r_instr && (funct3 == 3'b000) && !funct7[5];
    wire is_sub  = is_r_instr && (funct3 == 3'b000) &&  funct7[5];
    wire is_xor  = is_r_instr && (funct3 == 3'b100);
    wire is_or   = is_r_instr && (funct3 == 3'b110);
    wire is_and  = is_r_instr && (funct3 == 3'b111);

    wire is_addi = (opcode == 7'b0010011) && (funct3 == 3'b000);
    wire is_xori = (opcode == 7'b0010011) && (funct3 == 3'b100);
    wire is_ori  = (opcode == 7'b0010011) && (funct3 == 3'b110);
    wire is_andi = (opcode == 7'b0010011) && (funct3 == 3'b111);

    wire is_sll  = ((is_r_instr || (opcode == 7'b0010011)) &&
                    (funct3 == 3'b001) && !funct7[5]);
    wire is_srl  = ((is_r_instr || (opcode == 7'b0010011)) &&
                    (funct3 == 3'b101) && !funct7[5]);
    wire is_sra  = ((is_r_instr || (opcode == 7'b0010011)) &&
                    (funct3 == 3'b101) &&  funct7[5]);
    wire is_slt  = ((is_r_instr || (opcode == 7'b0010011)) &&
                    (funct3 == 3'b010));
    wire is_sltu = ((is_r_instr || (opcode == 7'b0010011)) &&
                    (funct3 == 3'b011));
    wire is_lui   = (opcode == 7'b0110111);
    wire is_auipc = (opcode == 7'b0010111);

    // Nuevas instrucciones de la Guia 5
    // Se detectan los cinco formatos de carga; esta etapa usa palabras completas.
    wire is_load = (opcode == 7'b0000011) &&
                   ((funct3 == 3'b000) || (funct3 == 3'b001) ||
                    (funct3 == 3'b010) || (funct3 == 3'b100) ||
                    (funct3 == 3'b101));

    // Comparador de Branch (Guia 3)
    wire is_beq  = is_b_instr && (funct3 == 3'b000);
    wire is_bne  = is_b_instr && (funct3 == 3'b001);
    wire is_blt  = is_b_instr && (funct3 == 3'b100);
    wire is_bge  = is_b_instr && (funct3 == 3'b101);
    wire is_bltu = is_b_instr && (funct3 == 3'b110);
    wire is_bgeu = is_b_instr && (funct3 == 3'b111);

    wire [31:0] src1_value, src2_value;

    wire taken_br =
        is_beq  ? (src1_value == src2_value) :
        is_bne  ? (src1_value != src2_value) :
        is_blt  ? ((src1_value < src2_value) ^ (src1_value[31] != src2_value[31])) :
        is_bge  ? ((src1_value >= src2_value) ^ (src1_value[31] != src2_value[31])) :
        is_bltu ? (src1_value < src2_value) :
        is_bgeu ? (src1_value >= src2_value) : 1'b0;

    wire [31:0] pc_plus4  = pc + 32'd4;
    wire [31:0] br_tgt_pc = instr_pc + imm;
    wire [31:0] alu_out;
    wire [31:0] jalr_tgt_pc = {alu_out[31:1], 1'b0};
    wire [31:0] next_pc = is_jalr ? jalr_tgt_pc :
                          (taken_br || is_jal) ? br_tgt_pc : pc_plus4;

    always @(posedge clk) begin
        if (rst)
            pc <= 32'd0;
        else if (state_execute)
            pc <= next_pc;
    end

    // ALU (sigue usando la ALU de 4 bits de la Guia 4)
    wire [3:0] alu_op =
        (is_jalr || is_load || is_s_instr || is_add || is_addi || is_lui || is_auipc) ? 4'b0000 :
        is_sub             ? 4'b0001 :
        is_sll             ? 4'b0010 :
        (is_xor || is_xori) ? 4'b0011 :
        (is_or || is_ori)   ? 4'b0100 :
        (is_and || is_andi) ? 4'b0101 :
        is_srl             ? 4'b0110 :
        is_sra             ? 4'b0111 :
        is_slt             ? 4'b1000 :
        is_sltu            ? 4'b1001 : 4'b0000;

    wire [31:0] alu_a = is_lui ? 32'b0 :
                        is_auipc ? instr_pc : src1_value;
    wire [31:0] alu_b = imm_valid ? imm : src2_value;


    alu rv_alu (
        .A(alu_a), .B(alu_b), .op(alu_op), .ALU_out(alu_out)
    );

    // Buses de la memoria de datos
    assign daddr     = alu_out;
    assign ddata_out = src2_value;
    assign dwr_en    = is_s_instr && (state_execute || state_execute2);
    assign drd_en    = is_load    && (state_execute || state_execute2);

    // En LOAD el dato llega desde DMEM; en JAL se guarda PC+4.
    wire [31:0] rf_wr_data = is_load ? ddata_in :
                             (is_jal || is_jalr) ? pc_plus_4 : alu_out;

    wire wr_en = is_valid &&
                 (is_add || is_sub || is_xor || is_or || is_and ||
                  is_addi || is_xori || is_ori || is_andi ||
                  is_sll || is_srl || is_sra || is_slt || is_sltu ||
                  is_lui || is_auipc || is_jal || is_jalr || is_load);

    RegisterFile rf (
        .clk(clk),
        .wr_en(wr_en && state_execute2),
        .wr_index(rd),
        .wr_data(rf_wr_data),
        .rd_index1(rs1),
        .rd_data1(src1_value),
        .rd_index2(rs2),
        .rd_data2(src2_value)
    );
endmodule
