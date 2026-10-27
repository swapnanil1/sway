# make check   everything that can be verified without a login session
# (sway/scripts/admin is included through the wildcard)
PYTHON_SCRIPTS := sway/scripts/add-to-heroic sway/scripts/display
SCRIPT_DIRS := $(patsubst %/,%,$(wildcard sway/scripts/*/))
SCRIPTS := install.sh sway/session/sway-desktop $(filter-out $(PYTHON_SCRIPTS) $(SCRIPT_DIRS),$(wildcard sway/scripts/*))

.PHONY: check syntax lint themes regression validate packages dry-run

check: syntax lint themes regression dry-run
	@echo "available repository checks completed"

syntax:
	@for f in $(SCRIPTS); do bash -n $$f || exit 1; done; echo "syntax    ok ($(words $(SCRIPTS)) scripts)"
	@python3 -c 'import ast, pathlib, sys; [ast.parse(pathlib.Path(p).read_text(), filename=p) for p in sys.argv[1:]]' $(PYTHON_SCRIPTS)

lint:
	@if command -v shellcheck >/dev/null; then shellcheck -S warning $(SCRIPTS) && echo "lint      ok"; \
	else echo "lint      skipped (shellcheck not installed)"; fi

themes:
	@sway/scripts/theme --check && echo "themes    ok ($$(ls themes/palettes | wc -l) palettes)"

regression:
	@python3 -m unittest discover -s tests -v

# Creates an isolated temporary home. Needs permission to open local sockets;
# it does not start installed services or reload the running compositor.
validate:
	@python3 tests/validate_configs.py

# needs pacman's sync databases; not part of `check`
packages:
	@grep -hvE '^\s*(#|$$)' packages/*.txt | while read -r p; do pacman -Si $$p >/dev/null 2>&1 || { echo "not in repos: $$p"; exit 1; }; done && echo "packages  ok"

dry-run:
	@./install.sh --dry-run >/dev/null && echo "installer ok (dry run)"
