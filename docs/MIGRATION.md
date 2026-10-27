# v2 → Sway: coexistence audit

Sway assumes a working Arch `plasma-meta` desktop: either a fresh Archinstall
setup or a desktop already used daily. Both can add Sway with the Sway installer. A user who ran v2 may still have shared settings from that
installer; installing Sway cannot reconstruct what existed before v2.

The `v2` branch and [V2-REFERENCE.md](V2-REFERENCE.md) preserve the old setup.
The latter is historical documentation, not Sway installation instructions.

## What changed

| v2 behavior | Sway behavior and reason |
| --- | --- |
| Standalone bootstrap with drivers, firmware, audio, login manager | Add Sway to working Plasma; reuse the host stack |
| `ly` enablement | Reuse the existing Plasma login setup; no display-manager installation |
| GNOME Keyring socket and browser `gnome-libsecret` flags | Leave the user's existing wallet/provider and browser choices alone |
| Generic portal configuration for every desktop | Install only `sway-portals.conf`; preserve KDE's backend choice |
| GTK settings, gsettings, qt6ct, KDE/Dolphin seeds | No shared application-theme writes; use Plasma's Qt integration |
| KDE color scheme and unrelated themes generated with Sway palette | Generate only Sway, Waybar, wofi, foot, mako and swaylock colors |
| Generic user service names and graphical-session ownership | Dedicated `sway-*` units, started/stopped by the Sway wrapper |
| XDG autostart sweep | Explicit small service list; launch other apps yourself |
| File associations, hidden/XWayland desktop launchers, service menus | Keep existing desktop/app integration untouched |
| Shell startup/fastfetch, fish configuration and shell change | No shell changes |
| `faillock deny=0`, reset failure counter | No authentication-policy edits |
| Membership in `input` for Caps Lock badge | No group change; omit that module |
| Power profile daemon enablement | Use the existing daemon if present; do not change system services |
| Maximum refresh, VRR and Alt/Super swap | Independent saved display profile; optional max refresh, VRR and swap; physical Super as Mod |
| Fixed Breeze cursor | Read Plasma's saved cursor theme/size at each Sway login |
| Symlinks directly into the checkout | Managed copy with backups; branch switches do not alter the installation |
| Large package selection | Sway companions plus reused KDE tools; optional utility package list |

GTK remains a dependency for several Sway tools and the fallback portal. That
does not install the GNOME desktop. Qt applications can use Plasma integration
in Sway without running the Plasma shell. Both desktops share your application's
settings and data; Sway is not a separate user profile.

The Sway portal override selects KDE for Settings and FileChooser, wlr for
screen capture, and GTK as fallback. KDE's backend starts on demand and is
stopped at Sway logout. This shares advertised appearance preferences, not
Sway's palette or monitor configuration; GTK applications may still follow
their own saved settings.

Use **Super+Shift+E → Display settings** inside Sway to configure its displays.
Closing the editor saves active outputs to `~/.config/sway-outputs.conf`,
which is preserved on reinstall. It does not import Plasma's display settings
or persist disabled outputs, HDR, color profiles or VRR. Cursor inheritance
only reads `kcminputrc`; its generated Sway include lives in the runtime
directory and is removed at logout. Personal overrides in
`~/.config/sway-local.conf` are loaded last.

## Automatic migration is intentionally narrow

The installer backs up an existing generic
`~/.config/xdg-desktop-portal/portals.conf` **only if it byte-matches** v2's seed.
It similarly retires v2's exact hidden `nm-applet.desktop` autostart override.
Customized files are preserved and need review. A user-level generic portal
file can override Plasma's distribution settings, while `sway-portals.conf`
affects only the Sway desktop ([upstream lookup rules](https://flatpak.github.io/xdg-desktop-portal/docs/portals.conf.html)).

Only the new namespaced services are installed. Sway does not disable arbitrary
existing user services, remove keyrings, change PAM or restore unknown previous
settings. Files that Sway replaces are backed up under
`~/.local/state/sway/backups/`. Existing v2 symlinks are backed up as symlinks,
not snapshots of their destinations: keep the old clone/branch available when
using those backups.

## Review on a machine previously installed with v2

Do this after saving work. Finish configuration from Plasma or a TTY; don't
reload a running v2 session while replacing its files. A fresh login/reboot
clears old processes and imported environment before assessing Sway.

- **Login:** confirm Plasma starts and your existing login manager offers it.
  Current Arch `plasma-meta` includes `plasma-login-manager`, not an SDDM
  requirement ([package dependencies](https://archlinux.org/packages/extra/any/plasma-meta/),
  checked 2026-10-27). Sway leaves that login setup in place. If the machine still
  only has standalone v2, establish a working Plasma desktop first; Sway does not
  migrate `ly` or another login manager for you.
- **Wallet:** inspect GNOME Keyring autostart/socket settings and browser flags
  such as `~/.config/chromium-flags.conf` and `.vscode/argv.json`. Do not delete
  keyrings or switch a browser's password backend before exporting/backing up
  the passwords it uses. KWallet being installed does not migrate old secrets.
- **Themes:** review `~/.config/gtk-3.0`, `gtk-4.0`, `qt6ct`, `kdeglobals`,
  `dolphinrc` and prior GNOME interface gsettings. Restore your preferred appearance
  through Plasma/application settings; Sway leaves these existing choices alone.
- **Portals:** review custom generic `portals.conf` and any user unit drop-ins
  that force a desktop value. `./install.sh --doctor` flags a generic file but
  does not rewrite a custom configuration. Plasma's packaged backend unit is
  `plasma-xdg-desktop-portal-kde.service`
  ([Arch package files](https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-kde/files/)).
- **Old session:** inspect old `sway-session.target`, `waybar.service`,
  `mako.service`, `polkit-agent.service`, `swayidle.service`, `cliphist.service`,
  `autotiling.service` and `wallpaper.*` links under `~/.config/systemd/user`.
  Remove/disable only those you identify as v2-owned, after leaving v2 and
  before installing this setup. In particular, remove old enablement links
  for `sway-session.target`, since the new setup reuses that name but starts
  it only through the wrapper. Don't globally enable the new units. The
  installer backs up and replaces an existing `sway-desktop` launcher and
  `sway-desktop.desktop` login entry when their contents differ.
- **Launchers:** review `~/.local/share/applications` for v2's hidden application
  entries and XWayland wrapper overrides. Check custom Dolphin service menus,
  `kservicemenurc` and MIME associations before restoring defaults.
- **Shell:** remove any unwanted v2 shellrc/fastfetch sourcing from `.bashrc` or
  fish startup yourself. Sway doesn't choose your shell.
- **System policy:** review `/etc/security/faillock.conf` for v2's `deny=0`, plus
  membership in `input`. Choose the appropriate policy for your machine; Sway
  does not infer it or edit system authentication. Keep drivers, PipeWire and
  power-management packages required by Plasma.

## Boundaries to test

The wrapper handles serial desktop switching, not simultaneous sessions for
one user. It doesn't start Plasma's shell or full autostart set under Sway. KDE
control panels are available on demand; a Wi-Fi password or wallet prompt may
still require an app/agent from your existing configuration.

No package uninstall, wallet migration or live-session restart happens during
installation. After deployment, follow the login/lock/portal/wallet acceptance
checks in the main README before treating this development version as ready
for daily use. In particular, check both directions of Plasma ↔ Sway switching.
