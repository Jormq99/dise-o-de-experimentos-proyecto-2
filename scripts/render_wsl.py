from __future__ import annotations

import argparse
import os
import platform
import random
import re
import subprocess
import sys
import time
import uuid
from datetime import datetime
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
REPOS_DIR = SCRIPT_DIR.parent.parent
PBRT_DIR = REPOS_DIR / "pbrt-v3"
RESULTS_DIR = SCRIPT_DIR.parent / "resultados"

# Las 4 escenas oficiales requeridas por el diseno experimental.
RENDERS = (
    (Path("scenes/test_scenes/dragon/f15-13.pbrt"), "f15-13.exr"),
    (Path("scenes/test_scenes/dragon/f8-4b.pbrt"), "f8-4b.exr"),
    (Path("scenes/test_scenes/dragon/f8-4a.pbrt"), "f8-4a.exr"),
    (Path("scenes/test_scenes/dragon/f9-3.pbrt"), "f9-3.exr"),
)

PBRT_ERROR = re.compile(r"\bError:", re.IGNORECASE)
PBRT_WARNING = re.compile(r"\bWarning:", re.IGNORECASE)
PBRT_STATISTICS = re.compile(r"^\s*Statistics:\s*$")


def build_directory(compiler: str) -> Path:
    build_root = Path(os.environ.get("PBRT_WSL_BUILD_ROOT", PBRT_DIR))
    return build_root / f"build-wsl-{compiler}"


def create_report(compiler: str, accelerator: str):
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    number = 1
    while True:
        report_path = RESULTS_DIR / (
            f"tiempos_wsl_{compiler}_{accelerator}_{number}.txt"
        )
        try:
            return report_path, report_path.open("x", encoding="utf-8", newline="\n")
        except FileExistsError:
            number += 1


def write_both(report, message: str) -> None:
    print(message, flush=True)
    report.write(message + "\n")
    report.flush()


def date_evidence() -> str:
    try:
        result = subprocess.run(
            ["date"], capture_output=True, text=True, check=True
        )
        return result.stdout.strip()
    except (OSError, subprocess.CalledProcessError) as exc:
        return f"No se pudo ejecutar date: {exc}"


def distribution() -> str:
    os_release = Path("/etc/os-release")
    if not os_release.is_file():
        return platform.platform()

    values = {}
    for line in os_release.read_text(encoding="utf-8", errors="replace").splitlines():
        key, separator, value = line.partition("=")
        if separator and key in {"PRETTY_NAME", "ID", "VERSION_ID"}:
            values[key] = value.strip().strip('"')
    return values.get("PRETTY_NAME", platform.platform())


def is_wsl() -> bool:
    if not sys.platform.startswith("linux"):
        return False
    if os.environ.get("WSL_DISTRO_NAME") or os.environ.get("WSL_INTEROP"):
        return True
    return "microsoft" in platform.release().lower()


def configured_compiler(build_dir: Path) -> tuple[str, str] | None:
    cache_path = build_dir / "CMakeCache.txt"
    if not cache_path.is_file():
        return None

    compiler_path = None
    compiler_id = None
    for line in cache_path.read_text(encoding="utf-8", errors="replace").splitlines():
        key, separator, value = line.partition("=")
        if not separator:
            continue
        cache_key = key.partition(":")[0]
        if cache_key == "CMAKE_CXX_COMPILER":
            compiler_path = value
        elif cache_key == "CMAKE_CXX_COMPILER_ID":
            compiler_id = value

    if compiler_id is None:
        for compiler_file in (build_dir / "CMakeFiles").glob(
            "*/CMakeCXXCompiler.cmake"
        ):
            for line in compiler_file.read_text(
                encoding="utf-8", errors="replace"
            ).splitlines():
                match = re.match(r'set\(CMAKE_CXX_COMPILER_ID "([^"]+)"\)', line)
                if match:
                    compiler_id = match.group(1)
                    break
            if compiler_id:
                break

    if compiler_path and compiler_id:
        return compiler_path, compiler_id
    return None


def patch_scene_accelerator(scene_path: Path, accelerator: str, compiler: str) -> Path:
    content = scene_path.read_text(encoding="utf-8", errors="replace")
    directive = re.compile(r'^\s*Accelerator\s+".*?"', re.MULTILINE)
    if directive.search(content):
        new_content = directive.sub(f'Accelerator "{accelerator}"', content, count=1)
    else:
        new_content = f'Accelerator "{accelerator}"\n' + content

    temp_scene_path = scene_path.with_name(
        f"{scene_path.stem}_{compiler}_{accelerator}_{os.getpid()}{scene_path.suffix}"
    )
    temp_scene_path.write_text(new_content, encoding="utf-8")
    return temp_scene_path


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Ejecutor de renders PBRT para WSL."
    )
    parser.add_argument(
        "--compiler",
        choices=["gcc", "clang"],
        required=True,
        help="Compilador usado para construir PBRT.",
    )
    parser.add_argument(
        "--accelerator",
        choices=["bvh", "kdtree"],
        required=True,
        help="Estructura de aceleracion que se configurara en las escenas.",
    )
    parser.add_argument(
        "--repetitions",
        type=int,
        default=1,
        help="Cantidad de repeticiones por escena (use 5 como minimo para el estudio).",
    )
    args = parser.parse_args()
    compiler = args.compiler
    accelerator = args.accelerator
    if args.repetitions < 1:
        parser.error("--repetitions debe ser al menos 1")

    if not is_wsl():
        print("Este script esta pensado para ejecutarse dentro de WSL.", file=sys.stderr)
        return 1

    build_dir = build_directory(compiler)
    pbrt_exe = build_dir / "pbrt"
    compiler_path = configured_compiler(build_dir)
    if not pbrt_exe.is_file() or not os.access(pbrt_exe, os.X_OK) or compiler_path is None:
        print(f"No se encontro un build WSL completo en: {build_dir}", file=sys.stderr)
        print("Configure y compile PBRT con estos comandos:", file=sys.stderr)
        print(
            f"  cmake -S {PBRT_DIR} -B {build_dir} -DCMAKE_BUILD_TYPE=Release "
            f"-DCMAKE_C_COMPILER={'gcc' if compiler == 'gcc' else 'clang'} "
            f"-DCMAKE_CXX_COMPILER={'g++' if compiler == 'gcc' else 'clang++'}",
            file=sys.stderr,
        )
        print(f"  cmake --build {build_dir} --parallel", file=sys.stderr)
        return 1
    expected_compiler_id = "GNU" if compiler == "gcc" else "Clang"
    compiler_path, compiler_id = compiler_path
    if compiler_id != expected_compiler_id:
        print(
            f"El build seleccionado usa {compiler_id} ({compiler_path}), "
            f"no el compilador {compiler.upper()}.\n"
            "Use un directorio de build separado para cada compilador.",
            file=sys.stderr,
        )
        return 1

    missing_scenes = [
        scene for scene, _ in RENDERS if not (PBRT_DIR / scene).is_file()
    ]
    if missing_scenes:
        print("No se encontraron estas escenas:", file=sys.stderr)
        for scene in missing_scenes:
            print(f"  {PBRT_DIR / scene}", file=sys.stderr)
        return 1

    try:
        report_path, report = create_report(compiler, accelerator)
    except OSError as exc:
        print(f"No se pudo crear el archivo de resultados: {exc}", file=sys.stderr)
        return 1

    failures = 0
    temp_scenes_created = []
    try:
        with report:
            write_both(report, "REPORTE DE RENDERS PBRT - WSL")
            write_both(report, f"Acelerador configurado: {accelerator.upper()}")
            write_both(report, f"Compilador seleccionado: {compiler.upper()}")
            write_both(report, f"Compilador CMake: {compiler_id} ({compiler_path})")
            write_both(report, f"Sistema operativo: {distribution()}")
            write_both(report, f"Kernel/plataforma: {platform.platform()}")
            write_both(report, f"Inicio: {datetime.now().astimezone().isoformat(timespec='seconds')}")
            write_both(report, f"Evidencia date: {date_evidence()}")
            write_both(report, f"Directorio de trabajo: {PBRT_DIR}")
            write_both(report, f"Ejecutable PBRT: {pbrt_exe}")
            write_both(report, f"Archivo de resultados: {report_path}")
            total_renders = len(RENDERS) * args.repetitions
            write_both(report, f"Repeticiones por escena: {args.repetitions}")
            write_both(report, f"Total de renders planificados: {total_renders}")

            for repetition in range(1, args.repetitions + 1):
                renders = list(RENDERS)
                random.shuffle(renders)
                write_both(report, "")
                write_both(report, f"REPETICION {repetition} DE {args.repetitions}")
                write_both(report, "Orden aleatorio de esta repeticion:")
                for index, (scene, _) in enumerate(renders, start=1):
                    write_both(report, f"  {index}. {scene}")

                for index, (scene, output_name) in enumerate(renders, start=1):
                    full_scene_path = PBRT_DIR / scene
                    active_scene_path = patch_scene_accelerator(
                        full_scene_path, accelerator, compiler
                    )
                    temp_scenes_created.append(active_scene_path)
                    rel_scene_arg = active_scene_path.relative_to(PBRT_DIR)
                    command = [str(pbrt_exe), str(rel_scene_arg)]
                    run_id = uuid.uuid4()

                    write_both(report, "=" * 78)
                    write_both(
                        report,
                        f"REPETICION {repetition}: RENDER {index} DE {len(renders)} "
                        f"{output_name} [{accelerator.upper()} + {compiler.upper()}]",
                    )
                    write_both(report, f"Identificador unico de corrida: {run_id}")
                    write_both(report, f"Escena base: {scene}")
                    write_both(report, f"Comando: {pbrt_exe} {rel_scene_arg}")
                    write_both(report, f"Inicio: {datetime.now().astimezone().isoformat(timespec='seconds')}")
                    write_both(report, f"Evidencia date: {date_evidence()}")
                    print("Salida de PBRT (el progreso no se guarda en el reporte):", flush=True)

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
                        message = f"Error al iniciar o leer PBRT: {exc}"
                        print(message, file=sys.stderr, flush=True)
                        diagnostics.append(message)

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
                    write_both(report, f"Evidencia date fin: {date_evidence()}")
                    write_both(report, f"Codigo de salida: {return_code}")
                    write_both(report, f"Estado: {status}")
                    write_both(report, f"Archivo de imagen esperado: {PBRT_DIR / output_name}")
                    write_both(report, "")

            write_both(report, "=" * 78)
            write_both(report, f"Renders correctos: {total_renders - failures} de {total_renders}")
            write_both(report, f"Renders con errores: {failures}")
            write_both(report, f"Fin: {datetime.now().astimezone().isoformat(timespec='seconds')}")
            write_both(report, f"Evidencia date fin: {date_evidence()}")
    finally:
        for temp_scene in temp_scenes_created:
            try:
                temp_scene.unlink()
            except OSError:
                pass

    print(f"\nResultados guardados en: {report_path}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
