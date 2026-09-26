# Copy over the keyboard layout set in Arch during install to niri input config
conf="/etc/vconsole.conf"
niriconf="$HOME/.config/niri/input.kdl"

if grep -q '^XKBLAYOUT=' "$conf"; then
  layout=$(grep '^XKBLAYOUT=' "$conf" | cut -d= -f2 | tr -d '"')
  sed -i "s|// layout \"us\"|layout \"$layout\"|" "$niriconf"
fi

if grep -q '^XKBVARIANT=' "$conf"; then
  variant=$(grep '^XKBVARIANT=' "$conf" | cut -d= -f2 | tr -d '"')
  sed -i "s|// variant \"\"|variant \"$variant\"|" "$niriconf"
fi
