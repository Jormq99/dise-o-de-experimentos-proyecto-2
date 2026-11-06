from __future__ import annotations

from render_vb import main as run_linux_vm_renderer


if __name__ == "__main__":
    raise SystemExit(
        run_linux_vm_renderer(
            platform_name="Hyper-V",
            build_root_env="PBRT_HYPERV_BUILD_ROOT",
            build_prefix="build-hyperv",
            report_prefix="hyperv",
        )
    )
