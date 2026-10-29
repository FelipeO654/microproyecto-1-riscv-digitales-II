`timescale 1ns / 1ps

module tb_alu;

    reg  [31:0] A;
    reg  [31:0] B;
    reg  [1:0]  alu_control;
    wire [31:0] ALUout;

    // Instanciación del Dispositivo Bajo Prueba (DUT)
    alu dut (
        .A(A),
        .B(B),
        .alu_control(alu_control),
        .ALUout(ALUout)
    );

    initial begin
        // Monitor de señales en consola (usando solo señales directas)
        $monitor("Tiempo = %0t ns | A = %0d (0x%h) | B = %0d (0x%h) | alu_ctrl = %b | ALUout = %0d (0x%h)",
                 $time, A, A, B, B, alu_control, ALUout, ALUout);

        // ======================================================
        // PRUEBAS DE LA ALU DE 32 BITS
        // ======================================================

        // 1. Operación Suma (ADD): alu_control = 2'b00
        A = 32'd100; B = 32'd50; alu_control = 2'b00; #10; // Resultado esperado: 150 (0x00000096)
        A = 32'd506; B = 32'd100; alu_control = 2'b00; #10; // Resultado esperado: 606 (0x0000025E)

        // 2. Operación Resta (SUB): alu_control = 2'b01
        A = 32'd100; B = 32'd50; alu_control = 2'b01; #10; // Resultado esperado: 50 (0x00000032)
        A = 32'd50;  B = 32'd100; alu_control = 2'b01; #10; // Resultado esperado: -50 (0xFFFFFFCE)

        // 3. Operación Lógica AND: alu_control = 2'b10
        A = 32'hFFFF0000; B = 32'hA5A5A5A5; alu_control = 2'b10; #10; // Resultado esperado: 0xA5A50000
        A = 32'h12345678; B = 32'h0000FFFF; alu_control = 2'b10; #10; // Resultado esperado: 0x00005678

        // 4. Operación Lógica OR: alu_control = 2'b11
        A = 32'hFF000000; B = 32'h000000FF; alu_control = 2'b11; #10; // Resultado esperado: 0xFF0000FF
        A = 32'h12340000; B = 32'h00005678; alu_control = 2'b11; #10; // Resultado esperado: 0x12345678

        $finish;
    end

endmodule
