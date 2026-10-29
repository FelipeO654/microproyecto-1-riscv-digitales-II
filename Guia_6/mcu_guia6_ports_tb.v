`timescale 1ns/1ps

module tb_mcu;
    reg clk = 0;
    reg rst = 1;
    reg [7:0] PORTC = 8'h5A;
    wire [7:0] PORTA;
    wire [7:0] PORTB;

    mcu mcuuq (
        .clk(clk), .rst(rst),
        .PORTA(PORTA), .PORTB(PORTB), .PORTC(PORTC)
    );

    wire [31:0] memoria100 = mcuuq.DMEM.mem[25];
    wire [31:0] x12 = mcuuq.cpu.rf.registers[12];
    wire [31:0] x13 = mcuuq.cpu.rf.registers[13];
    wire [31:0] x14 = mcuuq.cpu.rf.registers[14];

    always #2 clk = ~clk;
    initial begin
        $dumpfile("tb_mcu_guia6_ports.vcd");
        $dumpvars(0, tb_mcu);
        #9 rst = 0;
        #260;
        $display("--------------------------------");
        $display("GUIA 6 B: PORTA=%h PORTB=%h DMEM[100]=%0d", PORTA, PORTB, memoria100);
        if (PORTA === 8'h01 && PORTB === 8'hCA && memoria100 === 32'd202)
            $display("PUERTOS: CORRECTO");
        else
            $display("PUERTOS: REVISAR");
        $display("--------------------------------");
        $finish;
    end
endmodule
