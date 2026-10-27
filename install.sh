#!/usr/bin/env bash
# Add optional Sway to a fresh or established Arch plasma-meta desktop.
# Usage: ./install.sh [--dry-run] [--yes] [--extras] [--doctor]
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/sway"
DEST="$DATA/sway"
DRY_RUN=0 YES=0 EXTRAS=0 DOCTOR=0
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --yes) YES=1 ;;
        --extras) EXTRAS=1 ;;
        --doctor) DOCTOR=1 ;;
        -h|--help) sed -n '2,3s/^# //p' "$0"; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; exit 2 ;;
    esac
done
say() { printf '%s\n' "$*"; }
run() {
    if ((DRY_RUN)); then printf '[dry-run] '; printf '%q ' "$@"; printf '\n'; else "$@"; fi
}
# Existing content is retained in a unique backup directory for this run.
BACKUP="$STATE/backups/$(date +%Y%m%d-%H%M%S)-$$"
backup() {
    local path="$1" label="$2"
    if [[ -e $path || -L $path ]]; then
        run mkdir -p "$BACKUP/$(dirname "$label")"
        run mv -- "$path" "$BACKUP/$label"
    fi
}
link() {
    local src="$1" dst="$2" label="$3"
    if [[ -L $dst && $(readlink "$dst") == "$src" ]]; then return; fi
    backup "$dst" "$label"
    run mkdir -p "$(dirname "$dst")"
    run ln -s "$src" "$dst"
}
packages() { awk 'NF && $1 !~ /^#/ {print $1}' "$@" | sort -u; }
# Remove only exact v2 seeds that override every desktop, keeping a backup.
# Customized files are never silently removed.
retire_seed() {
    local src="$1" dst="$2" label="$3"
    if [[ -e $dst ]] && cmp -s "$src" "$dst"; then
        say "Back up unchanged v2 override: $dst"
        backup "$dst" "$label"
    fi
}
doctor() {
    local failed=0
    for item in "$CONFIG/sway/config" "$CONFIG/xdg-desktop-portal/sway-portals.conf" \
        "$CONFIG/systemd/user/sway-session.target" \
        /usr/local/bin/sway-desktop /usr/share/wayland-sessions/sway-desktop.desktop; do
        if [[ -e $item ]]; then say "OK: $item"; else say "MISSING: $item"; failed=1; fi
    done
    if [[ -f $CONFIG/xdg-desktop-portal/portals.conf ]]; then
        say 'REVIEW: generic portals.conf can override Plasma; see docs/MIGRATION.md.'
        failed=1
    fi
    for cmd in sway swaybg swayidle swaylock waybar foot wofi mako grim slurp wl-copy wl-paste \
        cliphist autotiling jq envsubst kreadconfig6 kcmshell6 dolphin pactl wdisplays python3 dbus-update-activation-environment; do
        command -v "$cmd" >/dev/null || { say "MISSING command: $cmd"; failed=1; }
    done
    say 'Runtime checks (login, locking, screen sharing, wallet and Plasma return) require both sessions; see README.'
    return "$failed"
}
if ((DOCTOR)); then doctor; exit; fi
if ((EUID == 0)); then say 'Run as your normal desktop user; sudo is used only for packages and the session entry.' >&2; exit 1; fi
# Existing helpers use ~/.config paths. Reject unsupported layouts explicitly.
if [[ $CONFIG != "$HOME/.config" ]]; then
    say 'Custom XDG_CONFIG_HOME is not supported by the inherited v2 helpers.' >&2; exit 1
fi
if [[ $HOME == *[[:space:]]* || $DATA == *[[:space:]]* ]]; then
    say 'Paths with whitespace are not supported by the inherited v2 helpers.' >&2; exit 1
fi
if ! ((DRY_RUN)); then
    for cmd in pacman sudo; do command -v "$cmd" >/dev/null || { say "Missing: $cmd" >&2; exit 1; }; done
    # Check the desktop component; the user may have removed the metapackage.
    # No login-manager package/service is required or changed here.
    pacman -Q plasma-workspace >/dev/null 2>&1 || {
        say 'Start with a working Arch Plasma desktop (for example Archinstall + plasma-meta). This installer adds Sway to it.' >&2; exit 1;
    }
fi
say 'Sway: optional session alongside KDE Plasma. No live session will be started or reloaded.'
package_lists=("$REPO/packages/sway.txt")
if ((EXTRAS)); then package_lists+=("$REPO/packages/extras.txt"); fi
mapfile -t pkgs < <(packages "${package_lists[@]}")
args=(-Syu --needed)
((YES)) && args+=(--noconfirm)
run sudo pacman "${args[@]}" "${pkgs[@]}"

# Use a managed copy: git switches/updates cannot rewrite the installed session.
# Reinstallation backs up the complete previous copy before replacing it.
backup "$DEST" installed-files
run mkdir -p "$DEST"
for dir in sway waybar wofi mako foot swaylock themes systemd; do
    run cp -a "$REPO/$dir" "$DEST/$dir"
done
if ! ((DRY_RUN)); then
    chmod +x "$DEST/sway/scripts/"* "$DEST/sway/session/sway-desktop"
    "$DEST/sway/scripts/theme" --no-reload onedark
fi
for dir in sway waybar wofi mako foot swaylock; do
    link "$DEST/$dir" "$CONFIG/$dir" "config/$dir"
done
for unit in "$REPO"/systemd/user/*; do
    name=$(basename "$unit")
    link "$DEST/systemd/user/$name" "$CONFIG/systemd/user/$name" "units/$name"
done
link "$DEST/sway/portals.conf" "$CONFIG/xdg-desktop-portal/sway-portals.conf" portals/sway-portals.conf
# This config only affects the wlr backend, not Plasma's KDE backend.
link "$DEST/sway/portal-wlr.conf" "$CONFIG/xdg-desktop-portal-wlr/config" portals/wlr-config
retire_seed "$REPO/seeds/xdg-desktop-portal/portals.conf" "$CONFIG/xdg-desktop-portal/portals.conf" portals/legacy-generic.conf
retire_seed "$REPO/autostart/nm-applet.desktop" "$CONFIG/autostart/nm-applet.desktop" autostart/nm-applet.desktop
# Session entry is independent of the clone path. Leave the existing login manager and its default session unchanged.
for spec in 'sway/session/sway-desktop /usr/local/bin/sway-desktop 755' \
            'sway/session/sway-desktop.desktop /usr/share/wayland-sessions/sway-desktop.desktop 644'; do
    read -r source target mode <<< "$spec"
    if [[ -e $target ]] && ! cmp -s "$REPO/$source" "$target"; then
        run sudo cp -a "$target" "$target.bak-$(date +%Y%m%d-%H%M%S)-$$"
    fi
    run sudo install -Dm"$mode" "$REPO/$source" "$target"
done
run systemctl --user daemon-reload
say "Installed copy: $DEST"
say "Backups (if needed): $BACKUP"
say 'Log out, select Sway at the existing login screen. Plasma remains available.'
say 'Log out of Plasma fully before using Sway to release its compositor VRAM.'
say 'Existing v2 users: review docs/MIGRATION.md; shared old settings are not blindly reset.'
