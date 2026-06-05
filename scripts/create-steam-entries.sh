#!/bin/bash
STEAMAPPS="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps"
LIBRARYCACHE="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/appcache/librarycache"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
mkdir -p "$ICON_DIR"

for acf in "$STEAMAPPS"/appmanifest_*.acf; do
    appid=$(grep '"appid"' "$acf" | grep -o '[0-9]\+')
    name=$(grep '"name"' "$acf" | head -1 | cut -d'"' -f4)

    # Find best icon from librarycache
    icon_src=$(find "$LIBRARYCACHE/$appid" -name "library_600x900.jpg" 2>/dev/null | head -1)
    [[ -z "$icon_src" ]] && icon_src=$(find "$LIBRARYCACHE/$appid" \( -name "*.jpg" -o -name "*.png" \) \
        ! -name "header.jpg" ! -name "library_hero*" ! -name "logo.png" 2>/dev/null | head -1)
    [[ -z "$icon_src" ]] && icon_src=$(find "$LIBRARYCACHE/$appid" -name "logo.png" 2>/dev/null | head -1)

    icon_path="$ICON_DIR/steam_icon_${appid}.png"
    if [[ -n "$icon_src" ]]; then
        magick "$icon_src" "$icon_path"
    else
        curl -sf "https://cdn.cloudflare.steamstatic.com/steam/apps/${appid}/capsule_sm_120.jpg" \
            | magick jpg:- "$icon_path"
    fi

    cat > "$DESKTOP_DIR/steam-${appid}.desktop" << ENTRY
[Desktop Entry]
Name=${name}
Exec=flatpak run com.valvesoftware.Steam steam://rungameid/${appid}
Icon=${icon_path}
Terminal=false
Type=Application
Categories=Game;
ENTRY
    echo "Created: $name ($appid)"
done
