#!/bin/bash

set -e  # Exit on any error

show_help() {
   echo "Nerd Fonts Installer Script"
   echo
   echo "Usage: $0 <FONT_ZIP_URL>"
   echo
   echo "Parameters:"
   echo "  <FONT_ZIP_URL>    Direct URL to a Nerd Font ZIP file"
   echo
   echo "Example:"
   echo "  https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraMono.zip"
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
   wget -P ~/.local/share/fonts $1
   cd ~/.local/share/fonts
   unzip ${ZIP_FILE_NAME}
   rm ${ZIP_FILE_NAME}
   fc-cache -fv
}

main $@
