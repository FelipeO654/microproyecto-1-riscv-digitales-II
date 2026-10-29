module alu (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [2:0]  op,
    output reg  [31:0] ALU_out
);

    always @(*) begin
        case (op)
            3'b000: ALU_out = A + B;       // ADD
            3'b001: ALU_out = A - B;       // SUB
            3'b010: ALU_out = A << B[4:0]; // SLL (Desplazamiento a la izquierda)
            3'b011: ALU_out = A ^ B;       // XOR
            3'b100: ALU_out = A | B;       // OR
            3'b101: ALU_out = A & B;       // AND
            default: ALU_out = 32'b0;
        endcase
    end

endmodule