systemctl --user enable --now omarchy-fcitx5.service
cp $OMARCHY_PATH/config/fcitx5/conf/xcb.conf ~/.config/fcitx5/conf/xcb.conf 2>/dev/null || true
cp $OMARCHY_PATH/config/fcitx5/conf/clipboard.conf ~/.config/fcitx5/conf/clipboard.conf 2>/dev/null || true
