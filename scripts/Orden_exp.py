"""
Orden_exp.py
Genera el plan de ejecución y orden aleatorio para los tratamientos experimentales de PBRT V3.
"""
import random
from pathlib import Path

SEMILLA = 20261025
REPETICIONES = 5
ACCELERADORES = ["bvh", "kdtree"]  # Secuencia de evaluación de estructuras de aceleración
SALIDA = Path("resultados/orden_ejecucion.txt")

# Escenarios experimentales actualizados (sin numeración interna, especificando hipervisores y compiladores)
ESCENARIOS = [
    "Windows nativo (MSVC)",
    "Linux nativo con GCC",
    "Linux nativo con Clang",
    "WSL 2 con GCC",
    "WSL 2 con Clang",
    "Hyper-V (Linux) con GCC",
    "Hyper-V (Linux) con Clang",
    "VirtualBox (Linux) con GCC",
    "VirtualBox (Linux) con Clang",
]

def generar():
    rng = random.Random(SEMILLA)
    lineas = [
        "Plan de Ejecucion Experimental - PBRT V3",
        f"Semilla de aleatorizacion: {SEMILLA}",
        f"Repeticiones por tratamiento: {REPETICIONES}",
        f"Secuencia de aceleradores por corrida: {', '.join(ACCELERADORES)}",
        f"Total de escenarios base de infraestructura/compilador: {len(ESCENARIOS)}",
        "",
    ]
    
    for rep in range(1, REPETICIONES + 1):
        orden = ESCENARIOS.copy()
        rng.shuffle(orden)
        lineas.append(f"--- Repeticion {rep} ---")
        for i, esc in enumerate(orden, 1):
            rng.shuffle(ACCELERADORES)
            lineas.append(f"  {i}. Entorno: {esc} | Orden de aceleradores: {ACCELERADORES[0]} -> {ACCELERADORES[1]}")
        lineas.append("")
    
    SALIDA.parent.mkdir(parents=True, exist_ok=True)
    SALIDA.write_text("\n".join(lineas), encoding="utf-8")
    print(f"Plan de ejecucion actualizado y escrito correctamente en {SALIDA}")

if __name__ == "__main__":
    generar()