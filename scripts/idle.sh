#!/bin/sh

# --- Configuration ---
MONITOR="eDP-1"
RESOLUTION="2560x1600"
SCALE="1.33"
ACTIVE_HZ="165"
IDLE_HZ="60"
IDLE_TIMEOUT=3

# --- Commands ---
# We use 'sh -c' to run multiple commands.
# First, we set the refresh rate. Second, we re-apply the scale to fix any UI glitches.
# We use 'preferred' and 'auto' to make the command more robust.
SET_ACTIVE_CMD="sh -c 'hyprctl keyword monitor \"${MONITOR},${RESOLUTION}@${ACTIVE_HZ},auto,${SCALE}\"'"
SET_IDLE_CMD="sh -c 'hyprctl keyword monitor \"${MONITOR},${RESOLUTION}@${IDLE_HZ},auto,${SCALE}\"'"

# --- Script ---
swayidle -w \
    timeout $IDLE_TIMEOUT "$SET_IDLE_CMD" \
    resume "$SET_ACTIVE_CMD"