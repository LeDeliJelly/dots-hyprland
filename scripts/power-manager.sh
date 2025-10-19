#!/bin/bash

# This script is designed to run in a minimal environment like one from `su -c`.

# Step 1: Find the User ID of the user running this script.
USER_ID=$(id -u)

# Step 2: Construct the full, absolute path to the Hyprland instance directory.
HYPRLAND_DIR="/run/user/${USER_ID}/hypr"

# Step 3: Check if the directory actually exists.
if [ ! -d "$HYPRLAND_DIR" ]; then
  # If it doesn't exist, Hyprland isn't running or is configured strangely. Exit.
  exit 1
fi

# Step 4: Find the instance signature by getting the latest file in that directory.
export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t "$HYPRLAND_DIR" | head -n 1)

# Step 5: Set the display for hyprctl to connect to.
export DISPLAY=:0

# Function to set the refresh rate
set_refresh_rate() {
    hz=$1
    hyprctl keyword monitor "eDP-1,2560x1600@${hz},auto,1.3333333"
}

# Main logic: check the argument and call the function.
if [ "$1" == "ac" ]; then
    set_refresh_rate 165
elif [ "$1" == "battery" ]; then
    set_refresh_rate 60
fi