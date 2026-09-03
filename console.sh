#!/bin/bash

DIR1="$HOME/.local/share/kio/servicemenus"
DIR2="$HOME/.local/share/kservices5/ServiceMenus"

mkdir -p "$DIR1" "$DIR2"

FILE_NAME="open_console_here.desktop"

cat << 'DESKTOP' > "$DIR1/$FILE_NAME"
[Desktop Entry]
Type=Service
X-KDE-ServiceTypes=KonqPopupMenu/Plugin
MimeType=all/all;
Actions=OpenHere;LaunchHome;
X-KDE-Priority=TopLevel

[Desktop Action OpenHere]
Name=Открыть консоль в текущей папке
Icon=utilities-terminal
Exec=bash -c 'TARGET="%f"; if [ -f "$TARGET" ]; then TARGET=$(dirname "$TARGET"); fi; if [ ! -d "$TARGET" ]; then TARGET="$HOME"; fi; konsole --workdir "$TARGET"'

[Desktop Action LaunchHome]
Name=Запустить консоль
Icon=utilities-terminal
Exec=bash -c 'konsole --workdir "$HOME"'
DESKTOP

cp "$DIR1/$FILE_NAME" "$DIR2/$FILE_NAME"
chmod +x "$DIR1/$FILE_NAME" "$DIR2/$FILE_NAME"

# Обновляем кэш служб KDE Plasma и перезапускаем Dolphin
kbuildsycoca6 --noincremental 2>/dev/null || kbuildsycoca5 --noincremental 2>/dev/null
killall dolphin 2>/dev/null

echo "Исправление установлено!"
