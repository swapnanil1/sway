# make check    everything that can be verified without a running session
SCRIPTS := install $(filter-out bin/lib,$(wildcard bin/*)) bin/lib/common.sh

.PHONY: check syntax lint themes keys sway packages dry-run

check: syntax lint themes keys sway dry-run
	@echo "all checks passed"

syntax:
	@for f in $(SCRIPTS); do bash -n $$f || exit 1; done; echo "syntax    ok ($(words $(SCRIPTS)) scripts)"

lint:
	@if command -v shellcheck >/dev/null; then shellcheck -x -S warning $(SCRIPTS) && echo "lint      ok"; \
	else echo "lint      skipped (shellcheck not installed)"; fi

themes:
	@bin/theme --check && echo "themes    ok ($$(ls themes/palettes | wc -l) palettes)"

keys:
	@bin/keys --check && echo "keys      ok"

# needs sway installed; skipped otherwise
sway:
	@if command -v sway >/dev/null; then bin/keys build && bin/theme --ensure && sway -C -c config/sway/config && echo "sway      ok"; \
	else echo "sway      skipped (sway not installed)"; fi

# needs pacman's sync databases; not part of `check`
packages:
	@grep -hvE '^\s*(#|$$)' packages/*.txt | while read -r p; do pacman -Si $$p >/dev/null 2>&1 || { echo "not in repos: $$p"; exit 1; }; done; echo "packages  ok"

dry-run:
	@./install --dry-run >/dev/null && echo "installer ok (dry run)"
