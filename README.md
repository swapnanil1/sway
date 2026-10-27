# Sway v3 — KDE first, Sway when you want it

**Version: 3.0.0-dev · branch: `v3` · Arch Linux**

Use KDE Plasma for everyday browsing and gaming. Log into Sway for tiling,
coding, tutorials, or a lighter desktop while running local models and large
builds. This adds the v2 Sway workflow to an **already working Plasma install**;
The expected starting point is either a fresh Archinstall + `plasma-meta`
desktop or a Plasma system you have already been using.

The `v2` branch remains the standalone setup. Its documentation is archived in
[docs/V2-REFERENCE.md](docs/V2-REFERENCE.md). Existing v2 users should read the
[migration audit](docs/V3-MIGRATION.md) before installing v3.

## How the two sessions fit together

| Area | Plasma | Sway v3 |
| --- | --- | --- |
| Desktop | Existing Plasma shell and KWin | Sway, Waybar, wofi, mako, foot |
| Common apps | Your existing apps | Same installed apps; Dolphin and KDE settings shortcuts |
| Login | Existing Plasma login setup | Adds a separate **Sway (v3)** entry |
| Themes | Managed in Plasma | Sway-only palette; KDE/GTK application settings stay shared |
| Audio/network | Existing system services | Uses the same services; no duplicate audio/network daemon |
| Passwords | Existing wallet/keyring | Leaves the provider and browser settings alone |
| Screen sharing | Existing KDE portal | wlr capture backend and GTK fallback |
| Startup | Normal Plasma startup | Explicit Sway services; no general desktop autostart sweep |

**Log out of Plasma fully before entering Sway.** A second concurrent session
would keep Plasma's compositor and applications in memory. The v3 launcher
refuses to start while it detects Plasma/KWin or an inherited Sway session for
the same user. Running both desktops concurrently under one user is not a
supported mode: they also share a D-Bus session and systemd user manager.

Sway can reduce desktop resource use, but there is no fixed VRAM saving. Open
browsers, Electron apps, GPU tools and models still consume memory. Measure
with the same applications and display setup in each session.

## Install

Start from an updated, functioning Arch `plasma-meta` desktop with working
networking, audio, graphics drivers and login. A fresh Archinstall setup and an
established Plasma desktop are both supported starting points.

As checked on 2026-10-27, Arch's [`plasma-meta` dependencies](https://archlinux.org/packages/extra/any/plasma-meta/)
include `plasma-login-manager`; SDDM is not a requirement of this setup. V3
reuses your existing login manager and adds its Wayland session entry without
installing, replacing or enabling a login manager.

The installer checks for `plasma-workspace`, the actual desktop component,
rather than requiring the metapackage itself to remain installed. It does not
install Plasma or choose a default login session for you.

From this repository, as your normal user:

```bash
./install.sh --dry-run
./install.sh
```

The real install uses `sudo pacman -Syu --needed` for the listed repository
packages, then installs the Sway files. Review pacman's full upgrade before
confirming it. There are no AUR helpers or downloaded installation scripts.

| Option | Purpose |
| --- | --- |
| `--dry-run` | Show actions without changing files, packages or services |
| `--extras` | Include optional DDC brightness, sensors and file utility packages |
| `--yes` | Pass `--noconfirm` to pacman |
| `--doctor` | Check installed paths/tools and report conflicting generic portal config |

Packages are listed in [packages/sway.txt](packages/sway.txt) and
[packages/extras.txt](packages/extras.txt). Existing KDE dependencies are reused
through `--needed`. The base includes Dolphin, KDE network/audio settings,
KDE's polkit agent, Plasma's Qt integration, and the Sway tools.

The installer supports the usual `~/.config` layout and home/data paths without
whitespace. It does not edit PAM, graphics drivers, shell startup, login-shell
selection, browser flags, MIME defaults or Plasma configuration. It does not
start a new session or reload the running compositor.

## Enter and leave Sway

1. Save your work and log out of Plasma.
2. At the existing login screen, select **Sway (v3)** and sign in.
3. `Super+Return` opens a terminal. `Super+Space` opens the launcher.
4. `Super+Shift+E` opens the session menu; choose logout to return to login.
5. Select Plasma to return to your primary desktop. A login manager may remember
   your last selection; v3 does not alter that preference.

If you use a TTY login instead of a display manager, run `sway-v3` after logging
out of the other graphical session. Use this wrapper, rather than plain `sway`,
so the v3 service cleanup runs when Sway exits.

At Sway startup, the wrapper environment and `session-start` select the Sway
portals and start `sway-v3-session.target`. It owns Waybar, mako, the KDE polkit
agent, idle locking, clipboard history and autotiling. On normal exit or a
compositor failure, the wrapper stops those services and clears the imported
display environment. These units are not globally enabled. A forced kill of the
wrapper or a system crash cannot run its exit trap; a reboot clears that state.

The `sway-portals.conf` override is desktop-specific, allowing Plasma to retain
its own backend selection ([portal configuration documentation](https://flatpak.github.io/xdg-desktop-portal/docs/portals.conf.html)).
Sway screen sharing offers an output picker, not individual windows. PipeWire
must already work for capture. The installer does not replace the audio stack.

Sway deliberately skips the general XDG autostart target. Cloud sync, password
manager tray apps and other desktop startup applications may need to be opened
manually. KWallet may prompt when first used; automatic unlock depends on your
existing login/PAM configuration. No credential migration is attempted.

Saved NetworkManager connections can reconnect normally. If a new Wi-Fi network
needs a password and the KDE control panel cannot get an agent in Sway, use
`nmcli --ask device wifi connect "SSID"` from a terminal; v3 does not run the
Plasma shell or a separate network tray agent.

## Retained workflow and defaults

| Shortcut | Action |
| --- | --- |
| `Super+Return` / `Super+T` | Terminal |
| `Super+Space` | App launcher |
| `Super+Tab` | Window switcher |
| `Super+E` | Dolphin |
| `Super+B` | Focus or launch your configured browser |
| `Super+1` … `Super+0` | Workspaces |
| `Super+V` | Clipboard history |
| `Print` | Screenshot area |
| `Super+Shift+X` | Lock |
| `Super+Shift+T` | Sway palette picker |
| `Super+Shift+Space` | Full shortcut list |
| `Super+U` | Focus the most recently urgent window |

V2's workspace rules, autotiling, screenshots, clipboard history, Pomodoro,
window tools, themes and animated urgent-workspace indicator remain. Applications
must actually emit an urgency/activation request for the indicator to react.
The current `focus_on_window_activation urgent` policy asks for attention
without jumping to another workspace.

The physical **Super** key is Mod; the v2 Alt/Super swap is now optional. Output
refresh selection and VRR use Sway's defaults unless you opt in. Optional
brightness/sensor tools show `N/A` when unavailable. The old evdev Caps Lock
module is disabled, so installation does not add you to the `input` group.

## Files, updates and personal settings

Installation copies the session into `~/.local/share/sway-v3` (or
`$XDG_DATA_HOME/sway-v3`) and links these config directories to it:

- `~/.config/{sway,waybar,wofi,mako,foot,swaylock}`
- `~/.config/systemd/user/sway-v3-*`
- `~/.config/xdg-desktop-portal/sway-portals.conf`
- `~/.config/xdg-desktop-portal-wlr/config`

Two system files provide the login entry: `/usr/local/bin/sway-v3` and
`/usr/share/wayland-sessions/sway-v3.desktop`. No display manager is enabled or
replaced. A differently named distro Sway entry may remain; choose **Sway (v3)**.

The installed copy is independent of the git checkout: changing branches does
not rewrite the session. Re-run the installer to deploy repository updates,
preferably from Plasma after logging out of Sway. Replaced user files and the
previous installed copy go into `~/.local/state/sway-v3/backups/<timestamp-pid>`.
Existing system entry files get adjacent timestamped backups if different.

Put personal Sway commands in **`~/.config/sway-v3-local.conf`**. It is included
last and is never replaced by the installer. For example:

```sway
# Optional v2 keyboard layout:
# input type:keyboard xkb_options altwin:swap_lalt_lwin
# Optional VRR:
# output * adaptive_sync on
```

For Waybar or other component changes, edit this repository and reinstall, or
keep your edits separately: edits inside the managed installed copy are backed
up on reinstall but are not merged into the new version. Choosing a new palette
changes only the Sway tools, not `kdeglobals` or GTK application settings.

Old seed, fish, fastfetch, MangoHud and KDE service-menu files remain in the
repository as v2 reference assets; v3 does not install them.

## Validation before daily use

Repository checks (Python and make; optional shellcheck/systemd-analyze):

```bash
make check
make validate    # headless Sway + unit syntax; needs local socket permissions
make packages    # checks local pacman sync databases; does not download/install
./install.sh --doctor
```

Installer/session tests use a temporary home and mocked privileged commands.
They check backups, coexistence, repeat installs, dry-run behavior and cleanup;
they do not install packages or switch your desktop.

Still test on the intended KDE system:

1. Plasma → Sway → Plasma login/logout, including two consecutive cycles.
2. Lock/unlock and suspend/resume; keyboard layout and external displays.
3. Browser/OBS screen sharing and file dialogs in both sessions.
4. Wi-Fi authentication, audio controls and wallet/password prompts.
5. In Plasma after returning, `systemctl --user is-active sway-v3-session.target`
   should report `inactive`; Waybar/mako should not still be running.
6. Compare idle VRAM/RAM with equivalent applications closed.

This is a development version until those real-session checks pass. Static and
mocked tests cannot establish hardware behavior or a particular VRAM saving.

## Remove or roll back

From Plasma after logging out of Sway, remove the `sway-v3.desktop` login entry
and `/usr/local/bin/sway-v3` with sudo. Remove only the user symlinks listed
above whose targets point into the managed Sway directory, restore the desired
files from your backup directory, then run `systemctl --user daemon-reload`.
Remove the managed copy only after saving personal edits. Keep packages required
by Plasma or other apps; do not blindly uninstall the package list. Old v2
system-wide changes require the separate migration review.
