from __future__ import annotations

import re
import random
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
REPOS_DIR = SCRIPT_DIR.parent.parent
PBRT_DIR = REPOS_DIR / "pbrt-v3"
PBRT_EXE = PBRT_DIR / "build" / "Release" / "pbrt.exe"
RESULTS_DIR = SCRIPT_DIR.parent / "resultados"

RENDERS = (
    (
        Path("scenes/test_scenes/dragon/f8-10.pbrt"),
        "f8-10.exr",
    ),
    (
        Path("scenes/test_scenes/dragon/f8-4b.pbrt"),
        "f8-4b.exr",
    ),
    (
        Path("scenes/test_scenes/dragon/f8-4a.pbrt"),
        "f8-4a.exr",
    ),
    (
        Path("scenes/test_scenes/dragon/f9-3.pbrt"),
        "f9-3.exr",
    ),
    (
        Path("scenes/test_scenes/bathroom/bathroom.pbrt"),
        "bathroom.exr",
    ),
)

PBRT_ERROR = re.compile(r"\bError:", re.IGNORECASE)
PBRT_WARNING = re.compile(r"\bWarning:", re.IGNORECASE)
PBRT_STATISTICS = re.compile(r"^\s*Statistics:\s*$")


def create_report():
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    number = 1
    while True:
        report_path = RESULTS_DIR / f"tiempos_windows_{number}.txt"
        try:
            return report_path, report_path.open(
                "x", encoding="utf-8", newline="\n"
            )
        except FileExistsError:
            number += 1


def write_both(report, message: str) -> None:
    print(message, flush=True)
    report.write(message + "\n")
    report.flush()


def main() -> int:
    renders = list(RENDERS)
    random.shuffle(renders)

    if not PBRT_EXE.is_file():
        print(f"No se encontro el ejecutable de PBRT: {PBRT_EXE}", file=sys.stderr)
        return 1

    missing_scenes = [scene for scene, _ in renders if not (PBRT_DIR / scene).is_file()]
    if missing_scenes:
        print("No se encontraron estas escenas:", file=sys.stderr)
        for scene in missing_scenes:
            print(f"  {PBRT_DIR / scene}", file=sys.stderr)
        return 1

    try:
        report_path, report = create_report()
    except OSError as exc:
        print(f"No se pudo crear el archivo de resultados: {exc}", file=sys.stderr)
        return 1

    failures = 0
    with report:
        write_both(report, "REPORTE DE RENDERS PBRT")
        write_both(report, f"Inicio: {datetime.now().astimezone().isoformat(timespec='seconds')}")
        write_both(report, f"Directorio de trabajo: {PBRT_DIR}")
        write_both(report, f"Archivo de resultados: {report_path}")
        write_both(report, "Orden aleatorio de esta ejecucion:")
        for index, (scene, _) in enumerate(renders, start=1):
            write_both(report, f"  {index}. {scene}")
        write_both(report, "")

        for index, (scene, output_name) in enumerate(renders, start=1):
            command = [str(PBRT_EXE), str(scene)]
            write_both(report, "=" * 78)
            write_both(report, f"RENDER {index} DE {len(renders)}: {output_name}")
            write_both(report, f"Escena: {scene}")
            write_both(report, f"Comando: .\\build\\Release\\pbrt.exe {scene.as_posix().replace('/', chr(92))}")
            write_both(report, f"Inicio: {datetime.now().astimezone().isoformat(timespec='seconds')}")
            print("Salida de PBRT (el progreso no se guarda en el reporte):", flush=True)
            report.flush()

            started = time.monotonic()
            error_seen = False
            return_code = -1
            statistics_started = False
            statistics_lines = []
            diagnostics = []
            try:
                process = subprocess.Popen(
                    command,
                    cwd=PBRT_DIR,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    encoding="utf-8",
                    errors="replace",
                    bufsize=1,
                )
                if process.stdout is None:
                    raise RuntimeError("No se pudo leer la salida de PBRT.")

                for line in process.stdout:
                    print(line, end="", flush=True)
                    if PBRT_ERROR.search(line):
                        error_seen = True
                        diagnostics.append(line.rstrip())
                    elif PBRT_WARNING.search(line):
                        diagnostics.append(line.rstrip())
                    if PBRT_STATISTICS.match(line):
                        statistics_started = True
                    if statistics_started:
                        statistics_lines.append(line.rstrip())
                return_code = process.wait()
            except (OSError, RuntimeError) as exc:
                message = f"Error al iniciar o leer PBRT: {exc}\n"
                print(message, end="", file=sys.stderr, flush=True)
                diagnostics.append(message.rstrip())

            elapsed = time.monotonic() - started
            success = return_code == 0 and not error_seen
            if not success:
                failures += 1
            status = "CORRECTO" if success else "FALLO"

            write_both(report, "")
            if diagnostics:
                write_both(report, "Mensajes de advertencia/error:")
                for diagnostic in diagnostics:
                    write_both(report, diagnostic)
                write_both(report, "")
            if statistics_lines:
                write_both(report, "ESTADISTICAS FINALES DE PBRT:")
                for statistics_line in statistics_lines:
                    write_both(report, statistics_line)
            else:
                write_both(report, "PBRT no produjo un bloque final de estadisticas.")
            write_both(report, f"Tiempo total: {elapsed:.1f} segundos ({elapsed / 60:.2f} minutos)")
            write_both(report, f"Codigo de salida: {return_code}")
            write_both(report, f"Estado: {status}")
            write_both(report, f"Archivo de imagen esperado: {PBRT_DIR / output_name}")
            write_both(report, "")

        write_both(report, "=" * 78)
        write_both(report, f"Renders correctos: {len(renders) - failures} de {len(renders)}")
        write_both(report, f"Renders con errores: {failures}")
        write_both(report, f"Fin: {datetime.now().astimezone().isoformat(timespec='seconds')}")

    print(f"\nResultados guardados en: {report_path}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
