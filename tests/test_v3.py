"""Installer/session regression checks; never install packages or touch the host session."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]


class V3Tests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="sway-v3-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / "home"
        self.home.mkdir()
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "commands"
        self.env = os.environ.copy()
        for key in list(self.env):
            if key.startswith("XDG_") or key in ("SWAYSOCK", "DISPLAY", "WAYLAND_DISPLAY"):
                self.env.pop(key)
        self.env.update(HOME=str(self.home), PATH=f"{self.bin}:{os.environ['PATH']}",
                        TEST_LOG=str(self.log))
        self.stub("pacman", '[[ "$*" == "-Q plasma-workspace" ]]')
        # Explicit allowlist: even a regression cannot run a privileged host operation.
        self.stub("sudo", '''printf 'sudo %s\n' "$*" >> "$TEST_LOG"
case "$1" in
  pacman) exit 0 ;;
  install) [[ "$4" == /usr/local/bin/sway-v3 || "$4" == /usr/share/wayland-sessions/sway-v3.desktop ]] ;;
  cp) [[ "$3" == /usr/local/bin/sway-v3 || "$3" == /usr/share/wayland-sessions/sway-v3.desktop ]] ;;
  *) exit 99 ;;
esac''')
        for cmd in ("systemctl", "dbus-update-activation-environment"):
            self.stub(cmd, f'printf \'{cmd} %s\\n\' "$*" >> "$TEST_LOG"')

    def stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/bash\nset -eu\n" + body + "\n")
        path.chmod(0o755)

    def run_script(self, script, *args, expected=0):
        result = subprocess.run([str(REPO / script), *args], env=self.env,
                                text=True, capture_output=True, timeout=30)
        self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        return result

    def seed(self, relative, content):
        path = self.home / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

    def test_dry_run_makes_no_changes(self):
        result = self.run_script("install.sh", "--dry-run", "--extras")
        self.assertIn("ddcutil", result.stdout)
        self.assertFalse(list(self.home.iterdir()))
        self.assertFalse(self.log.exists())

    def test_requires_existing_plasma(self):
        self.stub("pacman", "exit 1")
        self.run_script("install.sh", expected=1)
        self.assertFalse(self.log.exists())
        self.assertFalse(list(self.home.iterdir()))

    def test_install_and_reinstall_preserve_shared_settings_and_overrides(self):
        shared = [self.seed(p, f"keep {p}\n") for p in (
            ".config/kdeglobals", ".config/gtk-3.0/settings.ini", ".bashrc",
            ".config/chromium-flags.conf", ".config/mimeapps.list",
            ".config/xdg-desktop-portal/portals.conf", ".config/sway-v3-local.conf")]
        old_config = self.seed(".config/sway/config", "old sway config\n")
        snapshots = {p: p.read_bytes() for p in shared}
        self.run_script("install.sh", "--yes")
        self.assertTrue(old_config.parent.is_symlink())
        installed = self.home / ".local/share/sway-v3"
        self.assertTrue((installed / "sway/config.d/00_colors.conf").is_file())
        self.assertFalse((self.home / ".config/systemd/user/graphical-session.target.wants").exists())
        self.assertIn("default=gtk", (self.home / ".config/xdg-desktop-portal/sway-portals.conf").read_text())
        (installed / "personal-marker").write_text("preserve previous copy")
        self.run_script("install.sh")
        for path, data in snapshots.items():
            self.assertEqual(path.read_bytes(), data)
        backups = self.home / ".local/state/sway-v3/backups"
        self.assertEqual(len(list(backups.glob("*/config/sway/config"))), 1)
        self.assertEqual(len(list(backups.glob("*/installed-files/personal-marker"))), 1)
        commands = self.log.read_text()
        self.assertNotIn("--user start", commands)
        self.assertNotIn("--user stop", commands)
        self.assertNotIn("enable", commands)
        self.assertNotIn("gnome-keyring", commands)
        self.assertNotIn("chsh", commands)

    def test_exact_v2_portal_seed_is_backed_up(self):
        old = (REPO / "seeds/xdg-desktop-portal/portals.conf").read_text()
        path = self.seed(".config/xdg-desktop-portal/portals.conf", old)
        self.run_script("install.sh")
        self.assertFalse(path.exists())
        backups = list((self.home / ".local/state/sway-v3/backups").glob("*/portals/legacy-generic.conf"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), old)

    def test_wrapper_rejects_existing_plasma_without_stopping_it(self):
        self.stub("pgrep", "exit 0")
        self.run_script("sway/session/sway-desktop", expected=1)
        self.assertFalse(self.log.exists())

    def test_wrapper_cleans_up_after_compositor_failure(self):
        self.stub("pgrep", "exit 1")
        self.stub("sway", "exit 7")
        self.seed(".config/sway/env", (REPO / "sway/env").read_text())
        self.run_script("sway/session/sway-desktop", expected=7)
        commands = self.log.read_text()
        self.assertIn("stop sway-v3-session.target", commands)
        self.assertIn("unset-environment WAYLAND_DISPLAY DISPLAY SWAYSOCK", commands)
        self.assertNotIn("stop graphical-session.target", commands)

    def test_units_are_scoped_and_not_enabled_globally(self):
        folder = REPO / "systemd/user"
        for unit in folder.iterdir():
            self.assertTrue(unit.name.startswith("sway-v3-"))
            text = unit.read_text()
            self.assertNotIn("[Install]", text)
            self.assertNotIn("graphical-session.target", text)
            if unit.suffix != ".target":
                self.assertIn("PartOf=sway-v3-session.target", text)
        target = (folder / "sway-v3-session.target").read_text()
        for line in target.splitlines():
            if line.startswith("Wants="):
                for dependency in line.split("=", 1)[1].split():
                    self.assertTrue((folder / dependency).is_file(), dependency)


if __name__ == "__main__":
    unittest.main()
