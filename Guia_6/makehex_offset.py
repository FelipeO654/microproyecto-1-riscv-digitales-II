#!/usr/bin/env python3
# Formato hex con desplazamiento para la seccion SRAM que empieza en 0x1000.
import sys
from pathlib import Path

data = Path(sys.argv[1]).read_bytes()
size = int(sys.argv[2])
offset = int(sys.argv[3])
if len(data) % 4 or offset + len(data) // 4 > size:
    raise ValueError('Imagen SRAM no cabe o tamaño invalido')
for i in range(size):
    if offset <= i < offset + len(data) // 4:
        print(f'{int.from_bytes(data[(i-offset)*4:(i-offset+1)*4], "little"):08x}')
    else:
        print('00000000')
