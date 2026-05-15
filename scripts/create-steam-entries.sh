#!/bin/bash
STEAMAPPS="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps"
DESKTOP_DIR="$HOME/.local/share/applications"

for acf in "$STEAMAPPS"/appmanifest_*.acf; do
    appid=$(grep '"appid"' "$acf" | grep -o '[0-9]\+')
    name=$(grep '"name"' "$acf" | head -1 | cut -d'"' -f4)
    cat > "$DESKTOP_DIR/steam-${appid}.desktop" << ENTRY
[Desktop Entry]
Name=${name}
Exec=flatpak run com.valvesoftware.Steam steam://rungameid/${appid}
Icon=steam_icon_${appid}
Terminal=false
Type=Application
Categories=Game;
ENTRY
    echo "Created: $name ($appid)"
done
