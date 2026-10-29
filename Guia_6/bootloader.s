    .section .text
    .balign 16
    .globl _start
    .globl main
_start:
    # La ultima direccion es 0x3FFF, la pila crece hacia abajo.
    # 0x4000 es el primer byte libre y queda alineado a 16 bytes.
    li sp, 0x4000
    jal ra, main
fin_boot:
    bge x0, x0, fin_boot
