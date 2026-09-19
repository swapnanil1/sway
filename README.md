# sway desktop for Arch Linux

A complete sway (Wayland) desktop that installs on top of a bare Arch Linux
system with one script. Keyboard-driven, themeable, and set up for gaming.

* **Left-hand key layout** around the modifier and W A S D, defined in plain
  tables that also produce the searchable key list and the docs
* **15 colour themes**, switched live across sway, waybar, fuzzel, mako, foot,
  swaylock, fastfetch and the shell prompt
* **waybar with a tooltip on every module**: hover for detail, click for the tool
* **Gaming**: FreeSync, tearing for games that ask for it, game mode,
  per-purpose workspaces
* **Pomodoro** that enforces breaks and counts finished blocks, event sounds,
  drop-down terminal, annotated screenshots, clipboard history
* Session daemons are **systemd user units**; only official-repository packages

## Install

```
git clone <this repository> ~/sway-desktop
cd ~/sway-desktop
./install --dry-run    # shows every action, changes nothing
./install
reboot
```

Pick **sway** at the login screen. `./install --doctor` checks the result.
`--optional` adds night light, output profiles and shellcheck; `--fish` makes
fish the login shell; `--yes` skips pacman's confirmation.

Features that need hardware stay inactive without it: monitor brightness needs
a DDC/CI monitor, temperatures need a `k10temp`/`coretemp` and `amdgpu` sensor,
and the AMD packages are skipped without an `amdgpu` GPU.

## Keys

Mod is Super; left Alt and left Super are swapped so that Mod is under the left
thumb (`config/sway/config.d/10-input.conf`). `Mod+Shift+Space` lists every
binding, searchable, and Enter runs it. The full table is in
[docs/keys.md](docs/keys.md).

| Keys | Action |
| --- | --- |
| Mod + W A S D (+ Shift) | Focus (move window) |
| Mod + 1…5 (+ Shift) | Workspace: web, code, terminals, files, games (send window) |
| Mod + Space / Tab / Esc | Launcher / window switcher / previous workspace |
| Mod + T / Q / E / B | Terminal, drop-down terminal, files, browser |
| Mod + V / C | Clipboard history / screenshot |
| Mod + F (+ Shift) / R / G | Fullscreen (float) / resize mode / adjust mode |
| Mod + Shift + X E T Z G R | Lock, session menu, theme, pomodoro, game mode, reload |

## Documentation

* [Architecture](docs/architecture.md): layout, rules, how to add things
* [Keys](docs/keys.md): every binding
* [Theming](docs/theming.md)
* [Gaming](docs/gaming.md)

## Checks

```
make check       # syntax, shellcheck, palettes, templates, key tables, sway config, installer dry run
make packages    # every listed package exists in the repositories
```

## License

[MIT](LICENSE)
