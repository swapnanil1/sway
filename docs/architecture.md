# Architecture

The rules the repository follows, so that it stays small as it grows.

## Layout

| Path | Holds | Rule |
| --- | --- | --- |
| `config/` | One directory per tool, exactly as it appears under `~/.config` | `install` links every directory it finds. Adding a tool is adding a folder. |
| `bin/` | Every script | One purpose each, a usage header, `lib/common.sh` for anything shared. No script lives anywhere else. |
| `keys/` | Keybinding tables | The only place a binding is defined. |
| `themes/` | Palettes, templates, `targets.conf` | Data only. `bin/theme` has no knowledge of any tool. |
| `packages/` | Package names, one per line | Data only. |
| `seeds/` | Files copied once | For files their own application rewrites. Never overwritten. |
| `docs/` | Documentation | `keys.md` is generated. |

## Three directories outside the repository

| Path | Holds | Lifetime |
| --- | --- | --- |
| `~/.cache/sway-desktop/` | Generated config: colours per tool, built keybindings | Safe to delete; recreated at login and on reload |
| `~/.local/state/sway-desktop/` | Per-machine settings and history (sounds on/off, pomodoro history) | Kept across reboots |
| `$XDG_RUNTIME_DIR/sway-desktop/` | Scratch: timers, caches, locks | One login |

Nothing generated is ever written into the repository, so `git status` only
shows changes a person made.

## One source, several consumers

* **Keys.** `keys/*.keys` → the sway bindings, the searchable list
  (`Mod+Shift+Space`) and `docs/keys.md`. A description cannot go stale because
  it sits on the same line as the binding.
* **Colours.** `themes/palettes/<name>.conf` → one generated file per tool,
  which that tool's config includes. No config names a colour.

## Finding the scripts

`install` links the repository to `~/.local/share/sway-desktop`, wherever it was
cloned. Configs refer to `$bin` (sway) or that path (waybar, mako, systemd), and
scripts find each other through `lib/common.sh`. Nothing depends on `PATH` or
on the clone location.

## Failing safely

* A broken keys table keeps the previous bindings and says so.
* `config/sway/config` carries three static bindings (terminal, rebuild, exit)
  that work even if no generated file exists.
* The break screen restores sway from its parent process, so a crashed window
  cannot leave a mode with no keys.
* Every daemon is a systemd user unit: it restarts on failure and logs to the
  journal.

## Adding things

| To add | Do |
| --- | --- |
| A key | One line in a `keys/*.keys` table, then `Mod+Shift+R` |
| A theme | Copy a palette, change the colours |
| A themed tool | A template, a line in `themes/targets.conf`, an include in the tool's config |
| A tool | A folder under `config/`, its package in `packages/` |
| A session daemon | A unit in `config/systemd/user/`, its name in `sway-session.target` |

`make check` validates all of it without a running session.
