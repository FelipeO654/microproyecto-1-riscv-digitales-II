// ALU de 32 bits con operaciones usadas desde la Guia 4.
// Conserva las mismas entradas y codigos de operacion.
module alu(
    input [31:0] A,
    input [31:0] B,
    input [3:0] op,
    output reg [31:0] ALU_out
);
    always @(*) begin
        case (op)
            4'b0000: ALU_out = A + B;
            4'b0001: ALU_out = A - B;
            4'b0010: ALU_out = A << B[4:0];
            4'b0011: ALU_out = A ^ B;
            4'b0100: ALU_out = A | B;
            4'b0101: ALU_out = A & B;
            4'b0110: ALU_out = A >> B[4:0];
            4'b0111: ALU_out = $signed(A) >>> B[4:0];
            4'b1000: ALU_out = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            4'b1001: ALU_out = (A < B) ? 32'd1 : 32'd0;
            default: ALU_out = 32'b0;
        endcase
    end
endmodule
