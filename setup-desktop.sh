#!/usr/bin/env bash

# exit with error if WINEPREFIX is not set
if [[ -z "${WINEPREFIX:-}" ]]; then
  echo "WINEPREFIX is not set. Please set it to your Wine prefix path." >&2
  exit 1
fi

exe="$WINEPREFIX/drive_c/ntws/ntws.exe"
name="IBKR-Desktop"
desktop="$HOME/.local/share/applications/${name}.desktop"
icon_dir="$HOME/.local/share/icons/hicolor/256x256/apps"

mkdir -p "$icon_dir" "$(dirname "$desktop")"
tmpdir="$(mktemp -d)"
wrestool -x --type 14 "$exe" -o "$tmpdir"
icotool -x -o "$tmpdir" "$tmpdir"/*.ico
png="$(ls -1 "$tmpdir"/*.png | sort -V | tail -n1)"
cp "$png" "$icon_dir/${name}.png"

# The Exec line should point to run-ntws.sh in the C:\ntws\ directory,


cat > "$desktop" <<EOF
[Desktop Entry]
Name=$name Wine
Exec=$WINEPREFIX/drive_c/ntws/run-ntws.sh
Type=Application
Icon=$name
Categories=Wine;Application;
EOF

update-desktop-database "$HOME/.local/share/applications"

rm -rf "$tmpdir"

echo "Created desktop entry at $desktop"
