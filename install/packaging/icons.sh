# Copy all bundled icons to the hicolor icon directory
mkdir -p "$HOME/.local/share/icons/hicolor/512x512@2/apps"
mkdir -p "$HOME/.local/share/icons/hicolor/512x512/apps"

for icon in ~/.local/share/omarchy/applications/icons/*.png; do
  cp "$icon" "$HOME/.local/share/icons/hicolor/512x512@2/apps/"
  cp "$icon" "$HOME/.local/share/icons/hicolor/512x512/apps/"
  gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" &>/dev/null
done
