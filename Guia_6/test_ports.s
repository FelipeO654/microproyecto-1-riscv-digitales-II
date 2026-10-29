    .text
    .globl _start
_start:
    addi x12, x0, 0b11001010   # 202 = 0xCA
    addi x13, x0, 1
    sw x12, 100(x0)            # DMEM[25] = 202
    lui x14, 4                 # x14 = 0x4000
    sw x12, 4(x14)             # PORTB = CA
    sw x13, 0(x14)             # PORTA = 01
fin:
    bge x0, x0, fin
