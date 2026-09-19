# Shared helpers. Source it, never run it:
#   . "$(dirname "$(readlink -f "$0")")/lib/common.sh"
#
# Provides: ROOT BIN CACHE STATE RUNTIME, die, need, notify, is_gaming

set -u

BIN="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
ROOT="$(dirname "$BIN")"

# generated files (theme output, built keybindings): safe to delete
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/sway-desktop"
# per-machine settings and history that must survive reboots
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/sway-desktop"
# per-login scratch, private to the user
RUNTIME="${XDG_RUNTIME_DIR:-$CACHE/run}/sway-desktop"
mkdir -p "$CACHE" "$STATE" "$RUNTIME"

die() { printf '%s: %s\n' "${0##*/}" "$*" >&2; exit 1; }

# need <command>...: fail early with a useful message
need() {
	local cmd
	for cmd in "$@"; do
		command -v "$cmd" >/dev/null || die "missing command: $cmd"
	done
}

# notify <title> [body]: never blocks, never fails the caller
notify() { command -v notify-send >/dev/null && notify-send -a sway-desktop "$1" "${2:-}" || true; }

# setting <file> <key>: read KEY=value from a file under $STATE
setting() { sed -n "s/^$2=//p" "$STATE/$1" 2>/dev/null | tail -n1; }
# save <file> <key> <value>
save() {
	local file="$STATE/$1"
	{ grep -v "^$2=" "$file" 2>/dev/null; echo "$2=$3"; } >"$file.tmp" && mv "$file.tmp" "$file"
}

is_gaming() { [[ -e $RUNTIME/gamemode ]]; }
