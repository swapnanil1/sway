"""Exercise monitor profiles with mock IPC; never change real monitor settings."""
import copy
from importlib.machinery import SourceFileLoader
from importlib.util import module_from_spec, spec_from_loader
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
loader = SourceFileLoader("sway_display", str(REPO / "sway/scripts/display"))
spec = spec_from_loader(loader.name, loader)
display = module_from_spec(spec)
loader.exec_module(display)

OUTPUTS = [
    {"name": "DP-1", "active": True,
     "current_mode": {"width": 2560, "height": 1440, "refresh": 143970},
     "scale": 1.25, "rect": {"x": 0, "y": 0}, "transform": "normal"},
    {"name": "HDMI-A-1", "active": True,
     "current_mode": {"width": 1920, "height": 1080, "refresh": 60000},
     "scale": 1, "rect": {"x": -1080, "y": 0}, "transform": "90"},
    {"name": "eDP-1", "active": False, "current_mode": None},
]


class DisplayTests(unittest.TestCase):
    def test_profile_preserves_scaled_rotated_layout_and_fractional_refresh(self):
        text = display.profile(OUTPUTS)
        self.assertIn("mode 2560x1440@143.970Hz", text)
        self.assertIn("scale 1.25", text)
        self.assertIn("pos -1080 0", text)
        self.assertIn("transform 90", text)
        self.assertNotIn("eDP-1", text)
        self.assertNotIn("    disable", text)

    def test_rejects_empty_or_unusable_profiles(self):
        with self.assertRaises(ValueError):
            display.profile([])
        for key, value in (("name", 'DP-1"; exec bad'), ("scale", float("nan")),
                           ("transform", "bad"), ("scale", 0)):
            outputs = copy.deepcopy(OUTPUTS)
            outputs[0][key] = value
            with self.assertRaises(ValueError):
                display.profile(outputs)

    def test_save_backs_up_only_its_profile_and_does_not_apply_modes(self):
        with tempfile.TemporaryDirectory(prefix="sway-display-test-") as tmp:
            root = Path(tmp)
            config = root / ".config"
            config.mkdir()
            target = config / "sway-outputs.conf"
            target.write_text("# existing user arrangement\n")
            kde = config / "kwinoutputconfig.json"
            kde.write_text("KDE must remain untouched")
            tools = root / "bin"
            tools.mkdir()
            log = root / "calls"
            ipc = tools / "swaymsg"
            ipc.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$TEST_CALLS"\n'
                           'cat "$TEST_OUTPUTS"\n')
            ipc.chmod(0o755)
            data = root / "outputs.json"
            data.write_text(json.dumps(OUTPUTS))
            env = dict(os.environ, HOME=tmp, XDG_CONFIG_HOME=str(config),
                       PATH=f"{tools}:{os.environ['PATH']}", SWAYSOCK="mock",
                       TEST_CALLS=str(log), TEST_OUTPUTS=str(data))
            command = [str(REPO / "sway/scripts/display"), "save"]
            result = subprocess.run(command, env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(target.read_text(), display.profile(OUTPUTS))
            backups = list(config.glob("sway-outputs.conf.bak-*"))
            self.assertEqual(len(backups), 1)
            self.assertEqual(backups[0].read_text(), "# existing user arrangement\n")
            self.assertEqual(kde.read_text(), "KDE must remain untouched")
            self.assertEqual(log.read_text().strip(), "-r -t get_outputs")
            data.write_text("[]")
            result = subprocess.run(command, env=env, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(target.read_text(), display.profile(OUTPUTS))


if __name__ == "__main__":
    unittest.main()
