`timescale 1ns/1ps
module tb_riscv;
    reg [31:0] instr;
    reg clk;
    reg rst;
    integer i;
    riscv uut (.clk(clk), .rst(rst), .instr(instr));
    always #2 clk = ~clk;
    initial begin
        clk = 0;
        rst = 1;
        instr = 32'b0;
        $dumpfile("tb_riscv_guia2.vcd");
        $dumpvars(0, tb_riscv);
        for (i = 0; i < 32; i = i + 1) uut.rf.registers[i] = i;
        uut.rf.registers[0] = 32'b0;
        $monitor("Tiempo=%0t | clk=%b | instr=%h | IR=%h | imm=%h | imm_valid=%b | x4=%0d x5=%0d x6=%0d x7=%0d x8=%0d | x9=%0d x10=%0d x11=%0d x12=%0d",
            $time, clk, instr, uut.IR, uut.imm, uut.imm_valid,
            uut.rf.registers[4], uut.rf.registers[5], uut.rf.registers[6],
            uut.rf.registers[7], uut.rf.registers[8], uut.rf.registers[9],
            uut.rf.registers[10], uut.rf.registers[11], uut.rf.registers[12]);
        #3 rst = 0;
        instr = 32'b0000000_00010_00011_000_00100_0110011; #12; // ADD x4=5
        instr = 32'b0100000_00010_00011_000_00101_0110011; #12; // SUB x5=1
        instr = 32'b0000000_01100_01010_111_00110_0110011; #12; // AND x6=8
        instr = 32'b0000000_00010_00011_110_00111_0110011; #12; // OR x7=3
        instr = 32'b0000000_00010_00011_100_01000_0110011; #12; // XOR x8=1
        instr = 32'b000000000101_00011_000_01001_0010011; #12; // ADDI x9=8
        instr = 32'b000000000001_00011_111_01010_0010011; #12; // ANDI x10=1
        instr = 32'b000000000100_00011_110_01011_0010011; #12; // ORI x11=7
        instr = 32'b000000000110_00011_100_01100_0010011; #12; // XORI x12=5
        #12 $finish;
    end
endmodule
