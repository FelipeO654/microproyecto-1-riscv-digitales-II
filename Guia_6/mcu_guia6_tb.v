`timescale 1ns/1ps

module tb_mcu;
    reg clk = 0;
    reg rst = 1;
    reg [7:0] PORTC = 8'h33;
    wire [7:0] PORTA;
    wire [7:0] PORTB;

    mcu mcuuq (
        .clk(clk),
        .rst(rst),
        .PORTA(PORTA),
        .PORTB(PORTB),
        .PORTC(PORTC)
    );

    always #2 clk = ~clk;

    reg [7:0] anteriorA = 0;
    reg [7:0] anteriorB = 0;
    reg [7:0] esperadoB = 8'h02;
    integer cambiosA = 0;
    integer cambiosB = 0;
    reg errorA = 0;
    reg errorB = 0;

    always @(negedge clk) begin
        if (!rst) begin
            if (PORTA !== anteriorA) begin
                if (PORTA !== (anteriorA + 8'd1))
                    errorA = 1;
                else
                    cambiosA = cambiosA + 1;
                anteriorA = PORTA;
            end
            if (PORTB !== anteriorB) begin
                if (PORTB !== esperadoB)
                    errorB = 1;
                else
                    cambiosB = cambiosB + 1;
                anteriorB = PORTB;
                if (PORTB == 8'h80)
                    esperadoB = 8'h01;
                else
                    esperadoB = PORTB << 1;
            end
        end
    end

    initial begin
        $dumpfile("tb_mcu_guia6_c.vcd");
        $dumpvars(0, tb_mcu);
        $monitor("Tiempo=%0t | PORTA=%0d | PORTB=%b", $time, PORTA, PORTB);
        #9 rst = 0;
        #4000;
        $display("---------------------------------");
        $display("      RESULTADOS GUIA 6 C");
        $display("---------------------------------");
        $display("PORTA = %0d", PORTA);
        $display("PORTB = %b", PORTB);
        $display("Cambios PORTA = %0d", cambiosA);
        $display("Cambios PORTB = %0d", cambiosB);
        if (cambiosA >= 3 && cambiosB >= 3 && errorA == 0 && errorB == 0)
            $display("COMPILACION C: CORRECTA");
        else
            $display("COMPILACION C: REVISAR");
        $display("---------------------------------");
        $finish;
    end
endmodule
