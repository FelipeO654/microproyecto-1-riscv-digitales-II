    .text
    .globl _start
_start:
    addi a0, x0, 12     # x = 12
    addi a1, x0, 3      # y = 3
    jal ra, _funcion    # llama a funcion y guarda direccion de retorno
fin:
    jal x0, fin         # bucle al terminar
_funcion:
    add a0, a0, a1      # resultado: a0=15
    jalr x0, ra, 0      # return
