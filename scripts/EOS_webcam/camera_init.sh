#!/bin/bash

# Camera Virtual Setup Script
# Sets up a physical camera as a virtual camera device using gphoto2 and v4l2loopback

set -e  # Exit on any error

# Package list
PACKAGES=(
	"gphoto2"
	"ffmpeg"
	"v4l2loopback-dkms"
	"v4l2loopback-utils"
	"linux-headers-$(uname -r)"
	"vlc"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
	echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
	echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
	echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
	if [[ $EUID -eq 0 ]]; then
		print_error "Don't run this script as root!"
		exit 1
	fi
}

# Function to install dependencies
install_dependencies() {
	print_status "Checking and installing dependencies..."

	# Update package list
	sudo apt update

	for package in "${PACKAGES[@]}"; do
		if ! dpkg -l | grep -q "^ii  $package "; then
			print_status "Installing $package..."
			sudo apt install -y "$package"
		else
			print_status "$package is already installed"
		fi
	done

	print_status "All dependencies installed successfully"
}

# Function to check if camera is connected
check_camera() {
	print_status "Checking for connected camera..."

	# Run gphoto2 --summary and capture output
	if camera_output=$(LANG=C gphoto2 --summary 2>&1); then
		if echo "$camera_output" | grep -q "Could not detect any camera"; then
			print_error "No camera detected!"
			print_error "Please ensure your camera is:"
			print_error "  1. Connected via USB"
			print_error "  2. Turned on"
			print_error "  3. In the correct mode (not mass storage)"
			return 1
		else
			print_status "Camera detected successfully!"
			# Extract and display camera info
			if manufacturer=$(echo "$camera_output" | grep "Manufacturer:" | cut -d: -f2 | xargs); then
				print_status "Manufacturer: $manufacturer"
			fi
			if model=$(echo "$camera_output" | grep "Model:" | cut -d: -f2 | xargs); then
				print_status "Model: $model"
			fi
			return 0
		fi
	else
		print_error "Failed to run gphoto2 command"
		return 1
	fi
}

# Function to setup virtual camera
setup_virtual_camera() {
	print_status "Setting up virtual camera..."

	# Find available video device number
	video_nr=0

	print_status "Using video device: /dev/video$video_nr"

	# Load v4l2loopback module
	if sudo modprobe v4l2loopback card_label="Virtual Camera" video_nr="$video_nr"; then
		print_status "v4l2loopback module loaded successfully"
		print_status "Virtual camera device created: /dev/video$video_nr"
	else
		print_error "Failed to load v4l2loopback module"
		return 1
	fi

	# List available video devices
	print_status "Available video devices:"
	ls -la /dev/video* 2>/dev/null || print_warning "No video devices found"

	# Run the command in background and save PID to file
	nohup gphoto2 --stdout --capture-movie --quiet 2>/dev/null | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 /dev/video$video_nr -loglevel error -hide_banner 2>/dev/null &
	echo $! > ~/.camera_process.pid

	return 0
}

# Main execution
main() {
	print_status "Starting Camera Virtual Setup Script"

	# Check if running as root
	check_root

	# Install dependencies
	install_dependencies

	# Check camera connection
	if ! check_camera; then
		exit 1
	fi

	# Setup virtual camera
	if ! setup_virtual_camera; then
		exit 1
	fi

	print_status "Setup completed successfully!"
	print_status "Virtual camera is available at: /dev/video$video_nr"
	print_status ""
	print_status "You can now:"
	print_status "  1. Use the virtual camera in applications like Zoom, OBS, etc."
	print_status "  2. Test with VLC: vlc v4l2:///dev/video$video_nr"
}

main

