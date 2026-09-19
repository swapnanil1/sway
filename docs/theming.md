# Theming

`Mod+Shift+T` opens a picker; `bin/theme <name>` applies a palette directly.
sway, waybar, fuzzel, mako, foot, swaylock and fastfetch change together; the
fish prompt follows the terminal's colours. GTK and Qt applications are not
recoloured (change those with `nwg-look` and `kvantummanager`).

| File | Purpose |
| --- | --- |
| `themes/palettes/*.conf` | 15 named colours as `KEY=#rrggbb` |
| `themes/templates/*` | One colour file per tool. `${KEY}` is `#rrggbb`, `${KEY_HEX}` is the same without `#` |
| `themes/targets.conf` | `template | generated file | reload command` |

Palettes are parsed as data and never executed. Colours that would make prompt
segments or dim text unreadable on the background were raised to a contrast of
at least 4.5 (3.5 for dim text).

`bin/theme --check` validates every palette and every placeholder.
