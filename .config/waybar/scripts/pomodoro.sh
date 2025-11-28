#!/bin/bash

# Storage for the timer state
STATUS_FILE="/tmp/pomodoro_status"
ACTION=$1

# Function to start a timer (25 mins work, 5 mins break)
start_timer() {
    local minutes=$1
    local state=$2
    local end_time=$(($(date +%s) + minutes * 60))
    echo "$end_time|$state" > "$STATUS_FILE"
}

# Handle Clicks
if [ "$ACTION" == "toggle" ]; then
    if [ -f "$STATUS_FILE" ]; then
        # If running, stop it
        rm "$STATUS_FILE"
    else
        # Start Work (25 mins)
        start_timer 25 "work"
    fi
    exit 0
elif [ "$ACTION" == "break" ]; then
    # Start Break (5 mins)
    start_timer 5 "break"
    exit 0
fi

# --- Display Logic (The Loop) ---
if [ ! -f "$STATUS_FILE" ]; then
    # Timer is stopped
    echo '{"text": " Pomo", "class": "idle", "tooltip": "Left: Work (25m)\nRight: Break (5m)"}'
    exit 0
fi

# Read file
read -r end_time state < "$STATUS_FILE"
current_time=$(date +%s)
remaining=$((end_time - current_time))

if [ "$remaining" -le 0 ]; then
    # Timer finished
    rm "$STATUS_FILE"
    # Send notification (requires libnotify)
    notify-send "Pomodoro" "Timer Finished!"
    echo '{"text": " Done", "class": "idle"}'
else
    # Timer running
    minutes=$((remaining / 60))
    seconds=$((remaining % 60))
    time_fmt=$(printf "%02d:%02d" $minutes $seconds)
    
    if [ "$state" == "work" ]; then
        echo "{\"text\": \" $time_fmt\", \"class\": \"work\", \"tooltip\": \"Focus Time!\"}"
    else
        echo "{\"text\": \"cX $time_fmt\", \"class\": \"break\", \"tooltip\": \"Take a break\"}"
    fi
fi
