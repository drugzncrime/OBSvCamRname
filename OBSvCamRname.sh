#!/bin/bash

# Script to rename OBS Virtual Camera
# Run this script with sudo privileges

# Exit on any error
set -e

echo "Starting OBS Virtual Camera renaming process..."

# Step 1: Prompt user for the new virtual camera name
read -p "Enter the desired name for the OBS Virtual Camera: " CAMERA_NAME

# Step 2: Install v4l2loopback-dkms if not already installed
echo "Installing v4l2loopback-dkms..."
sudo apt install -y v4l2loopback-dkms

# Step 3: Unload existing v4l2loopback module
echo "Unloading existing v4l2loopback module..."
sudo modprobe -r v4l2loopback || true

# Step 4: Reload v4l2loopback with custom settings
echo "Reloading v4l2loopback with custom name: $CAMERA_NAME..."
sudo modprobe v4l2loopback video_nr=10 card_label="$CAMERA_NAME" exclusive_caps=1

# Step 5: List devices to verify changes
echo "Listing video devices..."
v4l2-ctl --list-devices

# Step 6: Create persistent configuration
echo "Creating persistent configuration for $CAMERA_NAME..."
sudo tee /etc/modprobe.d/v4l2loopback.conf > /dev/null << EOL
options v4l2loopback video_nr=10 card_label="$CAMERA_NAME" exclusive_caps=1
EOL

# Step 7: Update initramfs
echo "Updating initramfs..."
sudo update-initramfs -u

echo "OBS Virtual Camera renaming process completed."
echo "The virtual camera has been renamed to '$CAMERA_NAME'."
echo "Please reboot your system for changes to take effect."
