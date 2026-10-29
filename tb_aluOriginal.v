`timescale 1ns / 1ps

module tb_alu;

    reg  [7:0] A;
    reg  [7:0] B;
    reg  [1:0] op;
    wire [7:0] ALU_out;

    // Instanciación del Dispositivo Bajo Prueba (DUT)
    alu dut (
        .A(A),
        .B(B),
        .op(op),
        .ALU_out(ALU_out)
    );

    initial begin
        // Monitor de señales
        $monitor("Tiempo = %0t ns | A = %3d | B = %3d | op = %b | ALU_out = %3d (0x%h)",
                 $time, A, B, op, ALU_out, ALU_out);

        // ======================================================
        // PRUEBAS ORIGINALES
        // ======================================================

        // Suma
        A = 8'd15;  B = 8'd10; op = 2'b00; #10; // Resultado: 25

        // Resta
        A = 8'd20;  B = 8'd5;  op = 2'b01; #10; // Resultado: 15

        // AND
        A = 8'hCA;  B = 8'hA5; op = 2'b10; #10; // Resultado: 0x80

        // OR
        A = 8'hCA;  B = 8'hA5; op = 2'b11; #10; // Resultado: 0xEF

        // ======================================================
        // NUEVAS PRUEBAS
        // ======================================================

        // Suma
        A = 8'd100; B = 8'd50; op = 2'b00; #10; // Resultado: 150

        // Suma con cero
        A = 8'd0;   B = 8'd75; op = 2'b00; #10; // Resultado: 75

        // Resta
        A = 8'd80;  B = 8'd30; op = 2'b01; #10; // Resultado: 50

        // Resta con resultado cero
        A = 8'd45;  B = 8'd45; op = 2'b01; #10; // Resultado: 0

        // AND
        A = 8'hF0;  B = 8'hAA; op = 2'b10; #10; // Resultado: 0xA0

        // AND con cero
        A = 8'hFF;  B = 8'h00; op = 2'b10; #10; // Resultado: 0x00

        // OR
        A = 8'hF0;  B = 8'h0F; op = 2'b11; #10; // Resultado: 0xFF

        // OR con cero
        A = 8'h55;  B = 8'h00; op = 2'b11; #10; // Resultado: 0x55

        $finish;
    end

endmodule