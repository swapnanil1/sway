#!/bin/bash

# A script to capture the focused window on Sway, annotate with Satty, and save.
# Dependencies: sway, jq, grim, satty, notify-send , dunst
# sudo pacman -S --needed jq grim satty libnotify dunst 

# Directory where screenshots will be saved
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
# Ensure the directory exists
mkdir -p "$SCREENSHOT_DIR"

# Check if jq is installed, as it's required for robust parsing
if ! command -v jq &> /dev/null; then
    notify-send -u critical "Screenshot Failed" "jq is not installed. Please install it to use this script."
    exit 1
fi

# Get geometry of the focused window using swaymsg and jq.
# This is the core change from the Hyprland version.
GEOMETRY=$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')

# Check if we got valid geometry. This can fail if no window is focused.
# When you click on Waybar, the bar itself gets focus, so no window is focused.
# We will handle this by using a keybinding as the primary method.
if [[ -z "$GEOMETRY" ]]; then
    # A keybinding is a better way to trigger this. We'll add a notification to guide the user.
    notify-send -u critical "Screenshot Failed" "No focused window found.\nClicking the bar changes focus. Use a keybinding instead."
    exit 1
fi

# Generate the filename with timestamp
FILENAME="$SCREENSHOT_DIR/satty-$(date '+%Y%m%d-%H%M%S')-window.png"

# Execute the screenshot and annotation pipeline for the active window
grim -g "$GEOMETRY" -t ppm - | satty --filename - --output-filename "$FILENAME"

# Optional: Notify user upon success or cancellation
if [ -f "$FILENAME" ]; then
     # Add a small delay for the icon to be available for the notification
     sleep 1
     notify-send "Screenshot Saved" "Annotated window screenshot saved to:\n$FILENAME" -i "$FILENAME"
else
     # Satty might have been cancelled, or an error occurred
     notify-send -u normal "Screenshot Info" "Satty screenshot process was cancelled or failed."
fi

exit 0
