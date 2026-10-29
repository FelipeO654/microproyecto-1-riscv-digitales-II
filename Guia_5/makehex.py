import sys
from pathlib import Path

binario = Path(sys.argv[1]).read_bytes()
palabras = int(sys.argv[2])

if len(binario) % 4 != 0:
    raise SystemExit("Error: el binario no contiene palabras completas de 32 bits")
if len(binario) > palabras * 4:
    raise SystemExit("Error: el programa excede la capacidad de la ROM")

for i in range(palabras):
    dato = binario[4*i:4*i+4]
    print(f"{int.from_bytes(dato, 'little'):08x}")
