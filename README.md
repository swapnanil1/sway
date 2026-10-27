# Sway — KDE first, Sway when you want it

**Version: 3.0.0-dev · Arch Linux**

Use KDE Plasma for everyday browsing and gaming. Log into Sway for tiling,
coding, tutorials, or a lighter desktop while running local models and large
builds. This adds the v2 Sway workflow to an **already working Plasma install**;
The expected starting point is either a fresh Archinstall + `plasma-meta`
desktop or a Plasma system you have already been using.

The `v2` branch remains the standalone setup. Its documentation is archived in
[docs/V2-REFERENCE.md](docs/V2-REFERENCE.md). Existing v2 users should read the
[migration audit](docs/MIGRATION.md) before installing Sway.

## How the two sessions fit together

| Area | Plasma | Sway |
| --- | --- | --- |
| Desktop | Existing Plasma shell and KWin | Sway, Waybar, wofi, mako, foot |
| Common apps | Your existing apps | Same installed apps; Dolphin and KDE settings shortcuts |
| Login | Existing Plasma login setup | Adds a separate **Sway** entry |
| Themes | Managed in Plasma | Sway-only palette; KDE/GTK application settings stay shared |
| Audio/network | Existing system services | Uses the same services; no duplicate audio/network daemon |
| Passwords | Existing wallet/keyring | Leaves the provider and browser settings alone |
| Portals | Existing KDE selection | KDE appearance/file picker, wlr capture, GTK fallback |
| Displays | Plasma's display settings | Independent, saved Sway monitor profile |
| Cursor | Managed in Plasma | Reads Plasma's saved theme and size at login |
| Startup | Normal Plasma startup | Explicit Sway services; no general desktop autostart sweep |

**Log out of Plasma fully before entering Sway.** A second concurrent session
would keep Plasma's compositor and applications in memory. The Sway launcher
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
include `plasma-login-manager`; SDDM is not a requirement of this setup. Sway
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
2. At the existing login screen, select **Sway** and sign in.
3. `Super+Return` opens a terminal. `Super+Space` opens the launcher.
4. `Super+Shift+E` opens the session menu; choose logout to return to login.
5. Select Plasma to return to your primary desktop. A login manager may remember
   your last selection; Sway does not alter that preference.

If you use a TTY login instead of a display manager, run `sway-desktop` after logging
out of the other graphical session. Use this wrapper, rather than plain `sway`,
so the Sway service cleanup runs when Sway exits.

At Sway startup, the wrapper environment and `session-start` select the Sway
portals and start `sway-session.target`. It owns Waybar, mako, the KDE polkit
agent, idle locking, clipboard history and autotiling. On normal exit or a
compositor failure, the wrapper stops those services and clears the imported
display environment. These units are not globally enabled. A forced kill of the
wrapper or a system crash cannot run its exit trap; a reboot clears that state.

The `sway-portals.conf` override is desktop-specific, allowing Plasma to retain
its own backend selection ([portal configuration documentation](https://flatpak.github.io/xdg-desktop-portal/docs/portals.conf.html)).
In Sway, KDE provides the Settings and FileChooser portals on demand; GTK is
the fallback for other interfaces. This aligns portal-aware apps with KDE's
appearance preferences without running the Plasma shell. It does not force
every GTK app to use the same theme: app preferences and existing GTK settings
still apply. The KDE backend is stopped on Sway exit so it can restart in Plasma.
Sway screen sharing offers an output picker, not individual windows. PipeWire
must already work for capture. The installer does not replace the audio stack.

Sway deliberately skips the general XDG autostart target. Cloud sync, password
manager tray apps and other desktop startup applications may need to be opened
manually. KWallet may prompt when first used; automatic unlock depends on your
existing login/PAM configuration. No credential migration is attempted.

Saved NetworkManager connections can reconnect normally. If a new Wi-Fi network
needs a password and the KDE control panel cannot get an agent in Sway, use
`nmcli --ask device wifi connect "SSID"` from a terminal; Sway does not run the
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

## Appearance and monitor settings

At each Sway login, the launcher reads Plasma's saved cursor theme and size
from `kcminputrc`, using Breeze at size 24 if unavailable or invalid. It generates
`$XDG_RUNTIME_DIR/sway-cursor.conf` for the compositor and exports the same
cursor settings for applications. The runtime file is removed on exit; your
KDE configuration is never written. Changes made in Plasma take effect on the
next Sway login. Sway's palette remains independent of Plasma's global theme.

Configure Sway displays once using **Super+Shift+E → Display settings**. This
opens `wdisplays`; closing it saves the current active displays' resolution,
refresh rate, scale, position and rotation to **`~/.config/sway-outputs.conf`**.
Sway loads that file on subsequent logins or configuration reloads. Existing
profiles receive adjacent timestamped backups; reinstalling Sway preserves it.

Equivalent commands inside Sway:

```bash
~/.config/sway/scripts/display show         # preview current active outputs
~/.config/sway/scripts/display configure    # editor, then save on closing
~/.config/sway/scripts/display save         # save changes made with swaymsg
~/.config/sway/scripts/display max-refresh  # optional, not saved automatically
```

This profile is independent of Plasma's display configuration; it does not
import KScreen/KWin settings. Before you create it, Sway uses its defaults.
Disabled outputs are not saved, so disabling a monitor in the editor is not
persistent. HDR, color profiles and VRR require separate Sway configuration.
Review the profile after changing monitors or ports. Keyboard, mouse and idle
policies also remain Sway-specific; Plasma's settings panels do not configure
those Sway policies.

## Files, updates and personal settings

Installation copies the session into `~/.local/share/sway` (or
`$XDG_DATA_HOME/sway`) and links these config directories to it:

- `~/.config/{sway,waybar,wofi,mako,foot,swaylock}`
- `~/.config/systemd/user/sway-*`
- `~/.config/xdg-desktop-portal/sway-portals.conf`
- `~/.config/xdg-desktop-portal-wlr/config`

Two system files provide the login entry: `/usr/local/bin/sway-desktop` and
`/usr/share/wayland-sessions/sway-desktop.desktop`. No display manager is enabled or
replaced. The distro's `sway.desktop` entry is left intact. If the login screen
shows two entries named Sway, select the one provided by `sway-desktop.desktop`,
whose command is `/usr/local/bin/sway-desktop`.

The installed copy is independent of the git checkout: changing branches does
not rewrite the session. Re-run the installer to deploy repository updates,
preferably from Plasma after logging out of Sway. Replaced user files and the
previous installed copy go into `~/.local/state/sway/backups/<timestamp-pid>`.
Existing system entry files get adjacent timestamped backups if different.

Put personal Sway commands in **`~/.config/sway-local.conf`**. It is included
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
repository as v2 reference assets; Sway does not install them.

## Validation before daily use

Repository checks (Python and make; optional shellcheck/systemd-analyze):

```bash
make check
make validate    # headless Sway + unit syntax; needs local socket permissions
make packages    # checks local pacman sync databases; does not download/install
./install.sh --doctor
```

Installer/session tests use a temporary home and mocked privileged commands.
They check backups, coexistence, repeat installs, dry-run behavior, cursor
handoff, display-profile saving and cleanup;
they do not install packages or switch your desktop.

Still test on the intended KDE system:

1. Plasma → Sway → Plasma login/logout, including two consecutive cycles.
2. Lock/unlock and suspend/resume; keyboard layout and saved display layout,
   scale and refresh rate after another login.
3. Browser/OBS screen sharing and file dialogs in both sessions; check cursor
   size/theme and light/dark appearance in native and Flatpak apps.
4. Wi-Fi authentication, audio controls and wallet/password prompts.
5. In Plasma after returning, `systemctl --user is-active sway-session.target`
   should report `inactive`; Waybar/mako should not still be running.
6. Compare idle VRAM/RAM with equivalent applications closed.

This is a development version until those real-session checks pass. Static and
mocked tests cannot establish hardware behavior or a particular VRAM saving.

## Remove or roll back

From Plasma after logging out of Sway, remove the `sway-desktop.desktop` login entry
and `/usr/local/bin/sway-desktop` with sudo. Remove only the user symlinks listed
above whose targets point into the managed Sway directory, restore the desired
files from your backup directory, then run `systemctl --user daemon-reload`.
Remove the managed copy only after saving personal edits. Keep packages required
by Plasma or other apps; do not blindly uninstall the package list. Old v2
system-wide changes require the separate migration review.
