module mcu (input clk, input rst);
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

    sram_32x DMEM (
        .clk(clk), .addr(daddr[13:2]),
        .wr_en(dwr_en), .wr_data(ddata_out),
        .rd_en(drd_en), .rd_data(ddata_in)
    );
endmodule

// Memoria de instrucciones: 4096 palabras de 32 bits, lectura sincrona
module rom4096x32 (
    input clk,
    input [11:0] addr,
    output reg [31:0] data
);
    reg [31:0] mem [0:4095];
    initial $readmemh("test_program.hex", mem);

    always @(posedge clk)
        data <= mem[addr];
endmodule

// Memoria de datos: 4096 palabras de 32 bits
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

    always @(posedge clk) begin
        if (wr_en)
            mem[addr] <= wr_data;
        if (rd_en)
            read_reg <= mem[addr];
    end

    // Alta impedancia mientras la lectura no este habilitada
    assign rd_data = rd_en ? read_reg : 32'bz;
endmodule
