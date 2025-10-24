#!/bin/bash
# Screenshot full screen with Satty

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

FILENAME="$SCREENSHOT_DIR/satty-$(date '+%Y%m%d-%H%M%S')-full.png"

grim -t ppm - | satty --filename - --output-filename "$FILENAME"

if [ -f "$FILENAME" ]; then
    if command -v notify-send &>/dev/null; then
        notify-send "Screenshot Saved" "Full screenshot saved to:\n$FILENAME" -i "$FILENAME"
    else
        echo "Screenshot saved to $FILENAME"
    fi
else
    echo "Screenshot cancelled or failed"
fi
