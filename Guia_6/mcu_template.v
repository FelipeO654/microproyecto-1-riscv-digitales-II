// Microcontrolador RISC-V: CPU + IMEM + DMEM + tres puertos de E/S.
module mcu (
    input clk,
    input rst,
    output reg [7:0] PORTA,
    output reg [7:0] PORTB,
    input [7:0] PORTC
);
    wire [31:0] instr, iaddr;
    wire [31:0] daddr, ddata_in, ddata_out;
    wire dwr_en, drd_en;

    riscv cpu (
        .clk(clk), .rst(rst), .instr(instr), .iaddr(iaddr),
        .daddr(daddr), .ddata_in(ddata_in), .ddata_out(ddata_out),
        .dwr_en(dwr_en), .drd_en(drd_en)
    );

    rom4096x32 IMEM (
        .clk(clk), .addr(iaddr[13:2]), .data(instr)
    );

    // Decodificacion de direcciones, figura 21 de la Guia 6.
    wire is_dmem = (daddr[31:14] == 18'd0);
    wire is_porta = (daddr == 32'h00004000);
    wire is_portb = (daddr == 32'h00004004);
    wire is_portc = (daddr == 32'h00004008);

    wire mem_wr = dwr_en && is_dmem;
    wire mem_rd = drd_en && is_dmem;
    wire porta_wr = dwr_en && is_porta;
    wire portb_wr = dwr_en && is_portb;
    wire portc_rd = drd_en && is_portc;

    wire [31:0] mem_data;
    sram_32x DMEM (
        .clk(clk), .addr(daddr[13:2]),
        .wr_en(mem_wr), .wr_data(ddata_out),
        .rd_en(mem_rd), .rd_data(mem_data)
    );

    // Registros de salida de 8 bits.
    always @(posedge clk) begin
        if (rst) begin
            PORTA <= 8'b0;
            PORTB <= 8'b0;
        end else begin
            if (porta_wr) PORTA <= ddata_out[7:0];
            if (portb_wr) PORTB <= ddata_out[7:0];
        end
    end

    // Bus de lectura compartido, solo un dispositivo responde.
    assign ddata_in = mem_rd ? mem_data :
                      portc_rd ? {24'b0, PORTC} : 32'bz;
endmodule

module rom4096x32 (
    input clk,
    input [11:0] addr,
    output reg [31:0] data
);
    reg [31:0] mem [0:4095];
    initial $readmemh("test_program.hex", mem);
    always @(posedge clk) data <= mem[addr];
endmodule

module sram_32x (
    input clk,
    input [11:0] addr,
    input wr_en,
    input [31:0] wr_data,
    input rd_en,
    output [31:0] rd_data
);
    reg [31:0] mem [0:4095];
    reg [31:0] read_reg;

    // Contenido inicial de los datos globales del programa C.
    initial $readmemh("sram.hex", mem);

    always @(posedge clk) begin
        if (wr_en) mem[addr] <= wr_data;
        if (rd_en) read_reg <= mem[addr];
    end
    assign rd_data = rd_en ? read_reg : 32'bz;
endmodule
