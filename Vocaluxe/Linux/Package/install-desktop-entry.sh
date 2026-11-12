#!/bin/sh
# Adds Vocaluxe (from this folder) to the application menu of the current user
HERE="$(dirname "$(readlink -f "$0")")"
TARGET="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "$TARGET"
sed -e "s=INSTALLPATH=$HERE=g" "$HERE/Linux/Package/Vocaluxe.desktop" > "$TARGET/Vocaluxe.desktop"
echo "Created $TARGET/Vocaluxe.desktop"
