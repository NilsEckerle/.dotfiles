#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
	echo "Nerd Fonts Installer Script"
	echo
	echo "Usage: $0 <FONT_ZIP_URL>"
	echo
	echo "Parameters:"
	echo "  <FONT_ZIP_URL>    Direct URL to a Nerd Font ZIP file"
	echo
	echo "Example:"
	echo "	https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraMono.zip"
	echo
	echo "This script downloads and installs fonts to ~/.local/share/fonts/"
}

main() {
	# Check if URL argument is provided
	if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		show_help
		exit 0
	fi

	ZIP_FILE_NAME=$(basename "$1")

	log_info "downloading $1"
	wget -P ~/.local/share/fonts $1

	cd ~/.local/share/fonts

	log_info "unziping ${ZIP_FILE_NAME}"
	unzip ${ZIP_FILE_NAME}
	rm ${ZIP_FILE_NAME}

	log_info "updating fc cache"
	fc-cache -fv

	log_success "font ${ZIP_FILE_NAME%.zip} installed successful"

	# Use partial matching - remove common suffixes and search
	echo ----------
	log_info "New installed fonts"
	SEARCH_TERM=$(echo "${ZIP_FILE_NAME%.zip}" | sed 's/-[Ff]ont$//' | sed 's/[_-]/ /g')
	fc-list | grep -i "${SEARCH_TERM}" | awk -F: '{print $2}' | awk -F, '{print ($2 == "") ? $1 : $2}' | sed 's/^ *//'
}

main $@
