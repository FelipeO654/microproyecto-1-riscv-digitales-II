`timescale 1ns/1ps

module tb_mcu;

    reg clk = 0;
    reg rst = 1;

    reg [7:0] PORTC = 8'h00;

    wire [7:0] PORTA;
    wire [7:0] PORTB;

    mcu mcuuq (
        .clk(clk),
        .rst(rst),
        .PORTA(PORTA),
        .PORTB(PORTB),
        .PORTC(PORTC)
    );

    reg [31:0] ra;
    reg [31:0] a0;
    reg [31:0] a1;

    always @(negedge clk) begin
        ra = mcuuq.cpu.rf.registers[1];
        a0 = mcuuq.cpu.rf.registers[10];
        a1 = mcuuq.cpu.rf.registers[11];
    end

    always #2 clk = ~clk;

    initial begin
        $dumpfile("tb_mcu_guia6_jal.vcd");
        $dumpvars(0, tb_mcu);
        #9 rst = 0;
        #240;
        $display("--------------------------------");
        $display("GUIA 6 A: ra=%0d, a0=%0d, a1=%0d, PC=%0d", ra, a0, a1, mcuuq.cpu.pc);
        if (ra === 32'd12 && a0 === 32'd15 && a1 === 32'd3)
            $display("JAL/JALR: CORRECTO");
        else
            $display("JAL/JALR: REVISAR");
        $display("--------------------------------");
        $finish;
    end
endmodule
