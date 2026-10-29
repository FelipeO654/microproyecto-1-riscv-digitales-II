`timescale 1ns/1ps

module tb_mcu;
    reg clk = 0;
    reg rst = 1;

    mcu mcuuq (
        .clk(clk),
        .rst(rst)
    );

    // Senales auxiliares para visualizar memorias y registros
    // sin duplicar declaraciones de $dumpvars.
    wire [31:0] mem10 = mcuuq.DMEM.mem[4];
    wire [31:0] mem14 = mcuuq.DMEM.mem[5];
    wire [31:0] mem18 = mcuuq.DMEM.mem[6];
    wire [31:0] x5 = mcuuq.cpu.rf.registers[5];
    wire [31:0] x6 = mcuuq.cpu.rf.registers[6];
    wire [31:0] x7 = mcuuq.cpu.rf.registers[7];

    // Periodo del reloj: 4 ns
    always #2 clk = ~clk;

    initial begin
        $dumpfile("tb_mcu_guia5.vcd");
        $dumpvars(0, tb_mcu);

        #9 rst = 0;
        #240;

        $display("---------------------------------");
        $display("       RESULTADOS GUIA 5");
        $display("---------------------------------");
        $display("DMEM[0x10] = %0d", mem10);
        $display("DMEM[0x14] = %0d", mem14);
        $display("DMEM[0x18] = %0d", mem18);
        $display("x5 = %0d", x5);
        $display("x6 = %0d", x6);
        $display("x7 = %0d", x7);

        if (mem10 === 32'd12 && mem14 === 32'd23 &&
            mem18 === 32'd35 && x5 === 32'd12 &&
            x6 === 32'd23 && x7 === 32'd35)
            $display("VERIFICACION: CORRECTA");
        else
            $display("VERIFICACION: REVISAR RESULTADOS");

        $display("---------------------------------");
        $finish;
    end
endmodule
