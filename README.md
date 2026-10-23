# sway desktop for Arch Linux

A complete sway (Wayland) desktop that installs on top of a bare Arch Linux
system with one script: compositor, bar, launcher, notifications, lock screen,
themes and the same left-hand keyboard workflow as the i3 desktop this grew
out of. No X server, no picom, no xrandr: sway does all of that itself.

* **One command install**, safe to re-run, with a dry-run mode and a health check
* **KDE applications** (Dolphin, Kate, Gwenview, Okular, Ark) on native Wayland
  with the Breeze look, without the Plasma shell: sway is the desktop
* **A proper password dialog** for admin tasks, like Plasma's: no `sudo -E`
* **Left-hand key layout**: everything within reach of the modifier and W A S D
* **15 colour themes** switched live across sway, waybar, wofi, foot, mako,
  swaylock, fastfetch, MangoHud and the shell prompt
* **Searchable key list** generated from the config, so it is never out of date
* **Game mode**, a **pomodoro timer** that enforces breaks, event sounds, a
  drop-down terminal and per-purpose workspaces
* Session daemons run as **systemd user units**: they restart on failure and
  log to the journal. Nothing else is resident: no tray helpers, no stats
  daemons, no accessibility bus
* Only packages from the official repositories; nothing from the AUR

## First keys

Mod is the key under your left thumb (Super, swapped onto the left Alt key).
Everything else is listed by `Mod + Shift + Space`.

| Keys | Does |
| --- | --- |
| Mod + Space | App launcher |
| Mod + T | Terminal |
| Mod + E | File manager (Dolphin) |
| Mod + B | Browser: focuses it if open, starts it otherwise |
| Mod + Q | Drop-down terminal, same key hides it |
| Mod + Shift + Q | Close window |
| Mod + 1 … 5 | Workspaces: web, code, terminals, files, games |
| Mod + Shift + 1 … 5 | Send the window there |
| Mod + W A S D | Focus up, left, down, right |
| Mod + F | Fullscreen |
| Mod + C | Screenshot an area, then annotate |
| Mod + V | Clipboard history |
| Mod + Shift + T | Theme switcher |
| Mod + Shift + X | Lock the screen |
| Mod + Shift + E | Power menu: lock, logout, suspend, reboot, shutdown |
| Mod + Shift + Space | Every key, searchable; Enter runs it |

## Requirements

* Arch Linux or a derivative, with a normal user that can use `sudo`
* A network connection and `git`

Everything else is installed for you. Some features depend on hardware and
simply stay inactive without it:

| Feature | Needs |
| --- | --- |
| Variable refresh rate and tearing | A GPU whose kernel driver supports them (amdgpu does). `adaptive_sync` is asked for on every output; outputs that cannot do it ignore it. |
| Monitor brightness keys and bar module | A monitor that speaks DDC/CI (`ddcutil`). Shows `N/A` otherwise. |
| CPU and GPU temperature in the bar | `lm_sensors` labels `Tctl`/`Tdie`/`Package id 0` (CPU) and `edge`/`junction` (GPU). Shows `N/A` otherwise. |
| Network speed in the bar | Any interface with a default route; wired and Wi-Fi both work. |
| Power profile toggle in the bar | `power-profiles-daemon` with a CPU driver that exposes profiles (`amd-pstate`, `intel_pstate`). The module hides itself otherwise. |

## Install

```
git clone <this repository> ~/sway-desktop
cd ~/sway-desktop
./install.sh --dry-run    # shows every action, changes nothing
./install.sh
reboot
```

Log in through `ly` and pick **Sway Desktop** (not the plain "Sway" entry: that
one starts sway without the session environment). After the first login run
`./install.sh --doctor` to check sensors, brightness, audio and the session
units.

| Flag | Effect |
| --- | --- |
| `--dry-run` | Print what would happen, touch nothing |
| `--yes` | Pass `--noconfirm` to pacman |
| `--optional` | Also install `packages/optional.txt` (gammastep, CJK fonts, KCalc, Filelight, Partition Manager, kio-fuse, MangoHud) |
| `--no-themes` | Leave GTK theming alone: no gsettings changes |
| `--kripton` | Also clone the Kripton GTK theme and Colloid icons (not packaged for Arch) |
| `--fish` | Make fish the login shell |
| `--keep-lockout` | Keep the 10 minute lockout after 3 wrong passwords (see [Passwords](#passwords)) |
| `--no-caps-badge` | Do not add the user to the `input` group; the bar then shows no Caps Lock badge |
| `--doctor` | Only run the health checks |

The script is safe to re-run. Existing config directories are moved to
`<name>.bak-<timestamp>` before being replaced by symlinks into this
repository, so edits made under `~/.config/sway`, `~/.config/waybar`, … are
edits to your clone. A display manager that is already enabled is left alone.

## Keys

The layout is built for the left hand, and it fits a 60% keyboard: thumb on
**Mod**, fingers on W A S D. Mod is Super. The keyboard block in
`sway/config.d/06_hardware.conf` swaps left Alt and left Super so that Mod is
the key under the thumb; delete the `altwin` option there to keep the keys as
printed. Unlike X11, keyboards plugged in later get the swap too.

`Mod+Shift+Space` lists every binding with a description. It is searchable and
Enter runs the selected line. The list is read from the config: the `#:`
comment above each `bindsym` is its description, so add one when you add a key.

| Keys | Action |
| --- | --- |
| Mod + W A S D (+ Shift) | Focus (move window) |
| Mod + 1…5 (+ Shift) | Workspace: web, code, terminals, files, games (send window) |
| Mod + Esc / Tab | Previous workspace / window switcher |
| Mod + Space | App launcher |
| Mod + T / Q / E / B | Terminal, drop-down terminal, files, browser |
| Mod + V / C | Clipboard history / screenshot an area |
| Mod + Ctrl + C, Shift + Print | Screenshot the window / the whole screen |
| Mod + F (+ Shift) | Fullscreen (float) |
| Mod + R / G | Resize mode / adjust mode, both driven by W A S D |
| Mod + Z / X | Toggle split layout / tabbed |
| Mod + Ctrl + W S / A D / X | Volume / brightness / mute, one step |
| Mod + Shift + Q | Close window |
| Mod + Shift + Z X E G T I | Pomodoro, lock, session menu, game mode, theme, window info |
| Mod + Shift + C / R | Reload sway (sway has no restart; both keys reload) |

Adjust mode (Mod+G, nothing held): W S volume, A D brightness, X mute,
Q E previous/next track, Space play/pause, Z event sounds, Esc leaves. It
covers every key a compact keyboard lacks.

Workspaces 6…0, Return for a terminal, J K L ; for focus, and the media and
Print keys also work, for full-size keyboards. The volume and media keys also
work on the lock screen.

On the bar: scroll on brightness and volume, left click volume to mute, right
click volume or the microphone for the mixer, click CPU, temperatures or memory
for `htop`, click the speedometer next to CPU to cycle the power profile
(performance, balanced, power-saver), hover the clock for a calendar (right
click switches the format),
right click the logo for the session menu, left click it for the launcher.
The pomodoro module takes left (start, pause), middle (break now) and right
(stop) click, and scrolling shows the last seven days. A red CAPS badge
appears while Caps Lock is on.

## Features

### Workspaces

New windows go to a workspace by purpose: 1 web, 2 code, 5 games together
with everything Steam, Proton or Wine spawns for them (sub-launchers,
installers), 6 the launchers (Steam, Heroic, Epic, plus the Winetricks and
Protontricks dialogs), 7 chat and media (with Easy Effects as the equaliser),
8 settings. Rules match the window's `app_id` (native Wayland) or `class`
(XWayland) with case-insensitive patterns (`sway/config.d/02_rules.conf`), so
native, Flatpak and renamed builds of an app all match. `Mod+Shift+I` shows
both for the focused window when you want to add one.

### Colour themes

`Mod+Shift+T` opens a picker; `~/.config/sway/scripts/theme <name>` applies a
theme directly. It recolours sway, waybar, wofi, foot, mako, swaylock,
fastfetch, MangoHud and the KDE applications (through a generated KDE colour
scheme that `kdeglobals` names). The fish prompt and syntax colours follow the
terminal.
Other Qt applications follow it too, through a generated qt6ct palette. GTK
applications keep Breeze-Dark.

| Path | Purpose |
| --- | --- |
| `themes/palettes/*.conf` | One palette per file, 15 named colours as `KEY=#rrggbb` |
| `themes/templates/` | One colour file per tool with `${KEY}` placeholders (`${KEY_HEX}` drops the `#`, `${KEY_RGB}` is `r,g,b`) |
| `themes/targets.conf` | Which template is written where, and how that tool reloads |

* New theme: copy a palette and change the colours.
* New tool: add a template, add a line to `targets.conf`, and make the tool's
  config import the generated file.

The generated files are git-ignored, so switching themes never changes the
repository, and they are recreated whenever one is missing. mako, swaylock,
wofi and MangoHud cannot include a second file, so for those four the template
is the whole config: edit `themes/templates/mako.conf`, not
`~/.config/mako/config`, and `themes/templates/wofi.css`, not
`~/.config/wofi/style.css`.

Open foot and KDE windows keep their colours; new ones use the new theme.

### Wallpapers

One folder per theme, named like the palette, under `~/Pictures/Wallpapers/`
(the installer creates them). Paste images in. `scripts/wallpaper` shows a
random one from the active theme's folder, never the same twice in a row, and
falls back to images placed directly in `~/Pictures/Wallpapers/` when the
theme's folder is empty. `wallpaper.timer` runs it every 15 minutes (the
interval is in `systemd/user/wallpaper.timer`), and a theme change runs it
too, so the wallpaper follows the theme. A sway reload keeps the current one.
No slideshow daemon: a systemd timer and one `swaybg` per change.

Wallhaven's colour filter is the quick way to fill the folders:
`https://wallhaven.cc/search?colors=<hex>`, one colour at a time. Any hex
works in the URL; the site's own picker offers these swatches:

| | | | | | |
| --- | --- | --- | --- | --- | --- |
| `660000` | `990000` | `cc0000` | `cc3333` | `ea4c88` | `993399` |
| `663399` | `333399` | `0066cc` | `0099cc` | `66cccc` | `77cc33` |
| `669900` | `336600` | `666600` | `999900` | `cccc33` | `ffff00` |
| `ffcc33` | `ff9900` | `ff6600` | `cc6633` | `996633` | `663300` |
| `000000` | `999999` | `cccccc` | `ffffff` | `424153` | |

The two nearest to each palette, a starting point:

| Theme | Wallhaven colours |
| --- | --- |
| ayu | `ff9900` orange, `000000` black |
| catppuccin | `663399` purple, `333399` indigo |
| dracula | `663399` purple, `ea4c88` pink |
| everforest | `336600` forest, `669900` green |
| gruvbox | `cc6633` rust, `ffcc33` amber |
| kanagawa | `333399` indigo, `424153` slate |
| material | `0099cc` blue, `66cccc` teal |
| mono | `000000` black, `999999` grey |
| monokai | `cccc33` yellow, `ea4c88` pink |
| nord | `66cccc` ice, `424153` slate |
| onedark | `0066cc` blue, `cc3333` red |
| oxocarbon | `000000` black, `993399` magenta |
| rosepine | `993399` iris, `0099cc` pine |
| solarized | `0099cc` blue, `999900` olive |
| tokyonight | `333399` indigo, `0066cc` blue |

### Game mode

`Mod+Shift+G` pauses notifications, stops the idle lock, and turns off every
sway key except workspace switching and the key that leaves the mode, so key
combinations reach the game. There is no compositor to stop: a fullscreen
game is already scanned out directly, may tear and gets VRR whether game mode
is on or not. It only touches the user session; nothing system-wide changes.

### MangoHud

The in-game overlay, installed with `--optional`. `mangohud/` is linked to
`~/.config/MangoHud`: `presets.conf` holds the views, numbered 1 to 7 from
least to most detail, and `MangoHud.conf` is
written by the theme switcher from `themes/templates/mangohud.conf`, so the
HUD uses the desktop palette. A game started after a theme change picks it
up; a running one reloads it with MangoHud's own key, `Shift_L+F4`. Start a
game with `mangohud %command%` in its Steam launch options, or `mangohud
<game>` elsewhere.

The HUD keys sit on the right Shift and the punctuation cluster beside it, so
they fit a 60% keyboard and never meet sway's Mod:

| Keys | Does |
| --- | --- |
| Shift_R + \ | HUD on or off |
| Shift_R + ] | Cycle the view: fps (the default at start), temps, compact, full, bench, power, everything, off |
| Shift_R + [ | Cycle the frame cap: none, 141, 72 |
| Shift_R + ' | Move the HUD to the next corner |
| Shift_R + ; | Write a 60 second frametime log to `~/Videos/mangohud-logs` |

### Pomodoro

25 minutes of work, 5 minutes of break. A notification warns one minute
before a break; the break then takes over the screen until it ends, and
`Mod+Ctrl+Shift+B` skips it. Finished work blocks and breaks are counted per
day in `~/.local/state/pomo/history` (plain text, one line per day) and shown
next to the timer. In game mode breaks are announced but never enforced. The
bar module is one small shell loop that sleeps while the timer is stopped.

### Event sounds

Notifications, screenshots, login and logout, game mode, theme changes and
the pomodoro play a sound from a freedesktop sound theme. `Mod+G` then `Z`
toggles them; `~/.config/sway/scripts/sound volume-keys on` adds a blip to the
volume keys. They are silent in game mode. Each sound is one `pw-play` that
plays and exits; nothing listens in the background.

### Applications

Wayland first, X11 as the fallback, decided per app and never by you: a Qt app
tries Wayland then X11 (`QT_QPA_PLATFORM` in `sway/env`), GTK does the same by
default, Firefox and Electron are switched to Wayland in `sway/env` and the
browser flags seed, and XWayland is on for whatever is left (Steam, games).
`Mod+Shift+I` tells you which one a window ended up on.

The applications are KDE's: Dolphin (with kio-admin for "Open as
Administrator"), Kate, Gwenview, Okular, Ark, pavucontrol-qt for the mixer. The
only GTK ones left are Firefox, satty and nm-connection-editor, and the GTK
theme is Breeze too so they do not stand out.

KDE apps outside Plasma have one known weak spot: they read "which
applications exist" and "which context menu plugins exist" from a cache
(ksycoca) that Plasma keeps fresh and that needs a menu definition Plasma
ships. Without both, Dolphin's Open With list is empty and Ark's "Extract
here" entries misbehave. This setup installs Arch's menu definition
(`archlinux-xdg-menu`, selected by `XDG_MENU_PREFIX` in `sway/env`), builds
the cache at install time and refreshes it at every login. If a freshly
installed application does not show up in Open With before the next login:

```
kbuildsycoca6
```

### Admin tasks

`polkit-kde-agent` runs as a session unit and draws the Plasma password
dialog whenever something asks polkit for rights. That covers three cases:

* KDE apps (Partition Manager, Kate saving a root-owned file, Dolphin with
  kio-admin) run as you and ask polkit for a root helper. Nothing runs as
  root with a GUI.
* Timeshift and GParted run their GUI as root. Their launchers already handle
  Wayland: they grant root access to the display with `xhost` for the run
  and start the program through `pkexec`, which brings up the dialog. On
  minimal sway setups this fails only because `xorg-xhost` is missing or no
  agent is running; both are installed here, so the menu entries just work.
* Anything else that must run as root: `~/.config/sway/scripts/admin <command>`
  does what those launchers do, for any program.

### Context menu

Five entries of this setup's own in Dolphin's right-click menu, as KIO service
menus: `kde/servicemenus/`, installed executable into
`~/.local/share/kio/servicemenus`.

* **Extract here**, on anything bsdtar reads: tar with any compression, zip,
  7z, rar, cpio. It opens one floating terminal for the whole selection and
  extracts the archives one by one into the folder each is in, exactly as
  they are: no subfolder, no Ark. Files that already exist are listed first,
  and you pick overwrite, keep, skip the archive or quit. A summary stays on
  screen until a key is pressed. `~/.config/sway/scripts/extract-here` does
  the same from a terminal. Ark's own "Extract" submenu is switched off in
  the seeded `kservicemenurc`; Dolphin's context menu settings turn it back
  on.
* **Open with Code**, on folders and the folder background, with Code's own
  icon. The installer reads the command and icon from whichever Code is
  installed (Code OSS, VS Code, VSCodium) and skips the entry when there is
  none.

* **Add to Steam**, on a single Windows executable, when native Steam is
  installed. Right-click the game's `.exe` and select it to send the file to
  Steam as a non-Steam shortcut. In Steam, open the shortcut's **Properties →
  Compatibility**, enable **Force the use of a specific Steam Play
  compatibility tool**, and choose Proton before playing. This adds a
  shortcut; it does not install the game or run the executable. The helper
  `~/.config/sway/scripts/add-to-steam /path/to/game.exe` also works from a
  terminal. It uses Steam's shortcut handler, leaving library files to Steam.

* **Add to Heroic**, on a single Windows `.exe`. Install and open Heroic once,
  then quit it completely, including its tray icon. Right-click the game's
  executable and choose this action; open Heroic to see the sideloaded game.
  Choose Wine/Proton in its game settings before playing. Native/AppImage and
  Flatpak profiles are supported, but if both exist, use Heroic's own Add Game
  dialog to choose the intended library. Flatpak must have access to the game
  folder. The helper refuses changes while Heroic is running, skips duplicates,
  and backs up an existing `sideload_apps/library.json` beside it before updating.
  Heroic has no add-game URL handler, so this uses its sideload library format.
  It does not run the executable or install Heroic.

* **Convert to**, directly in Dolphin's right-click menu. Audio files offer
  MP3, M4A (AAC), Ogg (Vorbis), Opus, FLAC and WAV; video files also offer
  MP4 (H.264), MKV (H.264) and WebM (VP9). Select a target and conversion starts
  in a floating terminal with progress. The menus filter by MIME type, not
  individual codecs; FFprobe checks for the required stream before conversion.
  Audio targets extract sound from videos that have an audio track.
  MP4/MKV try GPU encoding through VA-API, with automatic CPU fallback if
  unavailable or unsuccessful. Decoding and filtering still run on the CPU;
  WebM and audio conversion use the CPU. Hardware and software presets can
  produce different quality and file sizes.
  Outputs go beside the originals as `name.converted.ext`, with numbers added
  when needed. Originals and existing files are never overwritten. Ctrl+C
  cancels the batch and removes partial output. Video presets keep the first
  video and audio tracks without subtitles; audio presets keep the first audio
  track. Lossy conversion can reduce quality; FLAC/WAV cannot restore lost quality.
  CLI: `~/.config/sway/scripts/convert-media --to mp3 -- file.mkv`.
  Only ordinary KDE service menus and the FFmpeg shell helper are used.

### Screenshots and recording

`grim` captures, `slurp` selects the area, and the image opens in `satty` for
cropping and annotation. Copy puts it on the clipboard; save writes it to
`~/Pictures/Screenshots`.

Screen recording is OBS, installed by default: add a "Screen Capture
(PipeWire)" source, pick a screen or region in the picker that pops up, and
record or stream. It goes through the same portal path as a browser sharing
its screen, so there is no recorder script or key to maintain.

### Capture indicators

Two red badges in the bar, each from the layer that actually sees the
capture, so they hold for every app whatever toolkit it uses:

* **Screen share and microphone**: waybar reads PipeWire's stream graph. All
  microphone capture goes through PipeWire here (native, PulseAudio and ALSA
  apps alike), and portal screen sharing does too, OBS included.
* **Camera**: webcams are opened through V4L2, below PipeWire, so the bar
  reads the kernel driver's use count, which is non-zero while any process
  holds a camera open. One small read every five seconds.

Not covered: an app that records the screen through its own wlroots
screencopy path instead of the portal (OBS with the `wlrobs` plugin rather
than its PipeWire source).

A phone as webcam (DroidCam from the AUR, which needs `linux-headers` for its
kernel module) works like any USB camera: it is a `/dev/video` device below
everything here, and its audio arrives through an ALSA loopback that PipeWire
shows as a microphone. The camera badge treats a virtual camera as in use
once an app reads from it, not merely while the phone is connected.

### Screen sharing

Browsers, Discord and OBS ask the portal, and `xdg-desktop-portal-wlr`
answers: `slurp` pops up, you click a screen or drag a region. wlroots
shares outputs and regions, not single windows, so an app's "window" tab
stays empty; pick a screen instead. Firefox has PipeWire capture on by
default; Chromium-family browsers get it from the seeded flags file. OBS
uses its "Screen Capture (PipeWire)" source.

### Misbehaving apps

Some apps run worse on Wayland than on XWayland: a bundled toolkit with no
Wayland plugin, popups that land in the wrong place, scaling that is off.
`sway/x11-apps.txt` lists .desktop ids that the installer pins to XWayland by
wrapping their command in `scripts/x11`; DaVinci Resolve is there by default.
For a one-off, `~/.config/sway/scripts/x11 <command>` does the same. In
Dolphin, Resolve and other XWayland windows look no different; `Mod+Shift+I`
tells you which path a window took. Resolve additionally needs the AMD OpenCL
runtime (`rocm-opencl-runtime`) to see the GPU; that is between you and its
AUR package.

### Shell

fish with a split `conf.d/` configuration and ten prompt styles, from a plain
one-liner to powerline segments; `prompt-style` opens a menu with a live
preview. `fastfetch` runs once per terminal, not in nested shells or editor
terminals.

## Layout

| Path | Purpose |
| --- | --- |
| `sway/` | sway config (`config.d/` is loaded in name order), window rules, session scripts, the session environment (`env`), launcher (`session/`) and the XWayland pin list |
| `waybar/`, `wofi/`, `foot/`, `mako/`, `swaylock/`, `fastfetch/` | Symlinked into `~/.config` |
| `mangohud/` | Symlinked to `~/.config/MangoHud`: the views, plus the themed `MangoHud.conf` |
| `kde/` | The generated KDE colour scheme and Dolphin's context menu entries (`servicemenus/`) |
| `fish/` | Copied once into `~/.config`: fish rewrites its own files |
| `systemd/user/` | `sway-session.target` and the daemons it starts |
| `seeds/` | Files copied once and then left to their tool (GTK, qt6ct, kdeglobals, portals, browser flags, dolphin) |
| `packages/` | Package lists, one name per line |
| `themes/` | Colour palettes and the templates they fill |

### Session

The login manager runs `/usr/local/bin/sway-desktop`, which loads
`~/.config/sway/env` (Wayland switches for Qt, Firefox and Electron, the
qt6ct platform theme, a UTF-8 locale) and then starts sway. sway runs
`sway/scripts/session-start` once per login: it hands the Wayland socket to
systemd and D-Bus and starts `sway-session.target`, which owns waybar, mako,
the polkit agent, swayidle, cliphist and autotiling, the wallpaper timer,
plus XDG autostart entries.

```
systemctl --user status waybar
journalctl --user -u waybar -b
systemctl --user mask autotiling.service    # stop a daemon from starting
```

Nothing else is resident. What runs at login is sway, waybar (with the
pomodoro loop inside it), mako, the polkit agent, swayidle, the clipboard
watcher and autotiling, plus PipeWire and the keyring; roughly 200 MB in all. The accessibility bus is switched off
in `sway/env`, nm-applet's autostart entry is hidden (the bar shows the
connection), and the system monitor is `htop` in a floating terminal rather
than a GUI with a stats daemon behind it. Portals and KDE's `kded6` start on
first use and then stay; that is the price of screen sharing and of the KDE
apps.

The screen locks after 10 minutes idle and the outputs power down after 15;
both values are at the top of `sway/scripts/idle`. A fullscreen window (a
video, a game) keeps the screen awake.

### Hardware

* **Refresh rate**: `sway/scripts/display` puts every output on its largest
  mode at the highest refresh rate it offers; no output name is hardcoded.
* **GPU**: `output * adaptive_sync on` asks for VRR (FreeSync) everywhere, and
  games (`steam_app_*`, gamescope) are allowed to tear. Both happen in the
  kernel driver; there is no Xorg driver or compositor to configure.
* **Brightness**: DDC/CI through `ddcutil`. The value is cached in
  `$XDG_RUNTIME_DIR/brightness`, so the bar never polls the monitor.
* **Power profiles**: the speedometer in the bar is waybar's
  `power-profiles-daemon` module, so it costs no polling: the daemon pushes
  changes over D-Bus. Orange means performance, green means power-saver.
  `powerprofilesctl` sets the same thing from a terminal.
* **Mouse**: flat acceleration profile, set in `06_hardware.conf`.
* **X11 apps**: XWayland is on, for Steam, games and Electron builds without
  Wayland support.

### Theming of applications

Breeze everywhere, dark by default.

* Qt and KDE apps: `qt6ct` is the platform theme (`QT_QPA_PLATFORMTHEME` in
  `sway/env`); the seeded `qt6ct.conf` selects the Breeze style, breeze-dark
  icons and the palette the theme switcher writes
  (`~/.config/qt6ct/colors/Sway.conf`). KDE apps additionally read
  `~/.config/kdeglobals` for their colour scheme (seeded: Sway, the matching
  KDE scheme); each one also has a Color Scheme entry in its Settings menu.
  The two must agree: KDE apps take some colours from each, which is how
  Dolphin's alternating rows once came out grey. Change the Qt side in
  `qt6ct`.
* GTK (Firefox, satty, Timeshift): `Breeze-Dark` from `breeze-gtk` with the
  same icons. `nwg-look` changes them; it writes
  `~/.config/gtk-3.0/settings.ini` and gsettings, and new windows pick the
  change up.
* Cursor: `breeze_cursors`, set for sway, GTK, Qt and XWayland alike.
* Wallpaper: see [Wallpapers](#wallpapers). Without any image the background
  is the theme colour.

Not installed on purpose: `kwallet` (gnome-keyring already provides the Secret
Service that browsers and Electron use, and two providers fight over it),
`plasma-integration` and `xdg-desktop-portal-kde` (an even more native look,
at the price of Plasma pieces; worth an experiment later, not a default).

### Portals

`seeds/xdg-desktop-portal/portals.conf` makes the wlr portal the default and
leaves file dialogs and the dark-mode setting to the GTK portal;
`seeds/xdg-desktop-portal-wlr/config` sets the screen picker. The portals are
restarted at every login so they see the current Wayland socket.

### Passwords

Arch locks an account for 10 minutes after 3 wrong passwords in a row
(`pam_faillock`), and that one module sits behind `sudo`, `swaylock`, the
polkit dialog and the login screen alike: a typo at the lock screen then
blocks `sudo` in the terminal. The installer sets `deny = 0` in
`/etc/security/faillock.conf`, which switches the lockout off everywhere
while failures are still logged, and clears any lockout in force. `sudo` still
gives up after three tries; just run it again. Pass `--keep-lockout` to leave
the system default alone. If you are ever locked out on another machine:

```
faillock --user $USER --reset
```

### Secrets

`gnome-keyring` is unlocked at login through the PAM hooks that `ly` ships.
Chromium-based browsers, VS Code and applications on the system Electron are
pinned to it with `--password-store=gnome-libsecret`, because they do not
recognise `sway` as a desktop and would otherwise pick a store unpredictably.
The same flags file switches them to native Wayland. This is skipped when
KWallet is installed.

## Making it yours

* Default applications: `sway/config.d/03_apps.conf` (terminal, file manager),
  `sway/scripts/focus-or-launch` (browser, from `xdg-settings`).
* Packages: edit `packages/*.txt`. `make packages` checks that every name
  still exists in the repositories.
* Workspace purposes: `sway/config.d/02_rules.conf` and the icons in
  `waybar/config.jsonc`.
* Launcher entries hidden by the installer: `wofi/hidden-apps.txt`.
* Machine-specific fish settings: `~/.config/fish/conf.d/99-local.fish`, which
  is not part of this repository.

## Checks

```
make check       # script syntax, shellcheck if installed, palettes and templates, systemd units, installer dry run
make packages    # every listed package exists in the repositories
```

## Defaults worth setting after install

```
xdg-mime default foot.desktop x-scheme-handler/terminal
xdg-settings set default-web-browser firefox.desktop
xdg-mime default org.kde.kate.desktop text/plain
xdg-mime default org.kde.gwenview.desktop image/png image/jpeg image/webp
xdg-mime default org.kde.okular.desktop application/pdf
```

## Not ported from the i3 desktop

* The USB plug watcher. On i3 it re-applied the keyboard options for a newly
  attached keyboard and played a sound. sway applies its input config to new
  devices by itself, which left a resident `udevadm monitor` for a sound
  alone, so it was dropped.
* picom's look: opacity, blur, shadows, fades. sway composites without
  effects, and the AUR fork that adds them is out by policy. foot keeps its
  own transparency.
* Thunar's custom actions and automount. Dolphin mounts a drive when you
  click it; nothing mounts by itself.
* "Restart i3" and "Restart the compositor" in the session menu: sway only
  reloads, and there is no separate compositor.

## License

[MIT](LICENSE)
