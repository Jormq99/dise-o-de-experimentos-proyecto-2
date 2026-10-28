"""
generar_orden.py
Genera orden_ejecucion.txt: 5 repeticiones x 5 escenarios, con orden
aleatorio dentro de cada repetición (semilla fija, reproducible).
"""
import random
from pathlib import Path

SEMILLA = 20261025
REPETICIONES = 5
ACCELERADORES = ["kdtree", "bvh"]
NIVELES_NUCLEOS = [4, 8, 14]          # factor del escenario 5
SALIDA = Path("resultados/orden_ejecucion.txt")

ESCENARIOS = [
    "Windows nativo",
    "Linux nativo con GCC",
    "WSL2 (Linux)",
    "Maquina virtual Linux sobre Windows",
    "Linux nativo con variacion de nucleos",
]

def generar():
    rng = random.Random(SEMILLA)
    lineas = [
        "Plan de ejecucion - PBRT V3",
        f"Semilla: {SEMILLA}",
        f"Repeticiones: {REPETICIONES}",
        f"Aceleradores: {', '.join(ACCELERADORES)}",
        "",
    ]
    for rep in range(1, REPETICIONES + 1):
        orden = ESCENARIOS.copy()
        rng.shuffle(orden)
        lineas.append(f"Repeticion {rep}:")
        for i, esc in enumerate(orden, 1):
            lineas.append(f"  {i}. {esc}")
        lineas.append("")
    SALIDA.write_text("\n".join(lineas), encoding="utf-8")
    print(f"Plan escrito en {SALIDA}")

if __name__ == "__main__":
    generar()