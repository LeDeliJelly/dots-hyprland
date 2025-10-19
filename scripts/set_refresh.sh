#!/bin/bash

# Find the laptop display (eDP)
MONITOR=$(hyprctl monitors | grep 'eDP' | awk '{print $2}')
if [ -z "$MONITOR" ]; then
    notify-send "Error" "Could not find a laptop display (eDP)."
    exit 1
fi

# --- READ CURRENT SETTINGS ---
# Get the full block of info for our specific monitor
MONITOR_INFO=$(hyprctl monitors | grep -A 10 "Monitor $MONITOR")

# Extract the current resolution and position from the second line (e.g., "1920x1080@144.000 at 0x0")
RES_LINE=$(echo "$MONITOR_INFO" | sed -n '2p')
CURRENT_RES=$(echo "$RES_LINE" | awk '{print $1}' | cut -d'@' -f1) # -> 1920x1080
CURRENT_POS=$(echo "$RES_LINE" | awk '{print $3}')                 # -> 0x0

# Extract the current scale from the line that starts with "scale:"
CURRENT_SCALE=$(echo "$MONITOR_INFO" | grep "scale:" | awk '{print $2}') # -> 1.25 or 1

# --- VALIDATE READ SETTINGS ---
# If any of these are empty, we failed to parse, so we exit safely.
if [ -z "$CURRENT_RES" ] || [ -z "$CURRENT_POS" ] || [ -z "$CURRENT_SCALE" ]; then
    notify-send "Script Error" "Could not parse current monitor settings for $MONITOR."
    exit 1
fi

# --- PROMPT FOR NEW REFRESH RATE ---
# We use the existing settings to make the prompt more informative.
PROMPT_TEXT="Refresh Rate for $MONITOR ($CURRENT_RES, scale: $CURRENT_SCALE):"
REFRESH_RATE=$(pkill fuzzel; echo "" | fuzzel --dmenu --prompt "$PROMPT_TEXT")

# If user hit Esc or entered nothing, exit.
if [ -z "$REFRESH_RATE" ]; then
    exit 0
fi

# Validate that the input is a number.
if ! [[ "$REFRESH_RATE" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    notify-send "Error" "'$REFRESH_RATE' is not a valid number."
    exit 1
fi

# --- WRITE NEW CONFIGURATION ---
# We build the full configuration string, preserving all the old settings and
# only swapping in the new refresh rate.
NEW_CONFIG="$MONITOR,$CURRENT_RES@$REFRESH_RATE,$CURRENT_POS,$CURRENT_SCALE"
hyprctl keyword monitor "$NEW_CONFIG"

# Send a confirmation notification with the full details.
notify-send "Display Settings Updated" "Set $MONITOR to $CURRENT_RES@${REFRESH_RATE}Hz with scale $CURRENT_SCALE."
