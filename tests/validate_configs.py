"""Validate generated Sway configuration and unit syntax without touching a login."""
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

REPO = Path(__file__).resolve().parents[1]


def run(argv, env):
    subprocess.run(argv, env=env, cwd=REPO, check=True, timeout=30)


with tempfile.TemporaryDirectory(prefix="sway-v3-validate-") as tmp:
    home = Path(tmp)
    env = {key: value for key, value in os.environ.items()
           if not key.startswith("XDG_") and key not in
           ("SWAYSOCK", "DISPLAY", "WAYLAND_DISPLAY", "DBUS_SESSION_BUS_ADDRESS")}
    env.update(HOME=tmp, XDG_CONFIG_HOME=str(home / ".config"), XDG_RUNTIME_DIR=tmp)
    if shutil.which("systemd-analyze"):
        units = home / "units"
        units.mkdir()
        files = []
        for source in (REPO / "systemd/user").iterdir():
            target = units / source.name
            # Check syntax/dependency ordering on machines without every package
            # installed. Executable availability is checked by installer --doctor.
            text = re.sub(r"^(Exec(?:Start|StartPre|Reload))=.*$",
                          r"\1=/usr/bin/true", source.read_text(), flags=re.M)
            target.write_text(text)
            files.append(str(target))
        unit_env = dict(env, SYSTEMD_UNIT_PATH=f"{units}:/usr/lib/systemd/user")
        run(["systemd-analyze", "--user", "--man=no", "verify", *files], unit_env)
        print("units: syntax and dependency graph verified (commands substituted)", flush=True)
    else:
        print("units: skipped (systemd-analyze not installed)", flush=True)
    if shutil.which("sway") and shutil.which("envsubst"):
        dest = home / ".local/share/sway-v3"
        dest.mkdir(parents=True)
        config = home / ".config"
        config.mkdir(exist_ok=True)
        for folder in ("sway", "themes", "waybar", "wofi", "foot", "mako", "swaylock"):
            shutil.copytree(REPO / folder, dest / folder)
            if folder != "themes":
                (config / folder).symlink_to(dest / folder)
        run([str(dest / "sway/scripts/theme"), "--no-reload", "onedark"], env)
        env.update(WLR_BACKENDS="headless", WLR_RENDERER="pixman")
        run(["sway", "--validate", "--config", str(config / "sway/config")], env)
        print("sway: generated configuration validated headlessly", flush=True)
    else:
        print("sway: skipped (sway/envsubst not installed)", flush=True)
