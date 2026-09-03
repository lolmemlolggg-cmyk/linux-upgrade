#!/usr/bin/env bash

echo "Настройка принудительного закрытия для панели задач KDE Plasma..."

python3 - << 'EOF'
import os, glob, re

desktop_dirs = [
    '/usr/share/applications',
    '/var/lib/flatpak/exports/share/applications',
    os.path.expanduser('~/.local/share/applications')
]
out_dir = os.path.expanduser('~/.local/share/applications')
os.makedirs(out_dir, exist_ok=True)

count = 0
for d in desktop_dirs:
    if not os.path.exists(d):
        continue
    for filepath in glob.glob(os.path.join(d, '*.desktop')):
        filename = os.path.basename(filepath)
        out_path = os.path.join(out_dir, filename)

        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()

            if '[Desktop Action ForceQuit]' in content:
                continue

            exec_match = re.search(r'^Exec=\s*([^\s\n]+)', content, re.MULTILINE)
            if not exec_match:
                continue

            raw_bin = exec_match.group(1).replace('"', '').strip()
            binary_name = os.path.basename(raw_bin)

            if not binary_name or binary_name.startswith('%'):
                continue

            if 'Actions=' in content:
                content = re.sub(r'^(Actions=.*)$', r'\1ForceQuit;', content, flags=re.MULTILINE)
            else:
                content = re.sub(r'(\[Desktop Entry\]\n)', r'\1Actions=ForceQuit;\n', content)

            action_block = (
                f"\n[Desktop Action ForceQuit]\n"
                f"Name=Принудительное закрытие (Все процессы)\n"
                f"Name[ru]=Принудительное закрытие (Все процессы)\n"
                f"Exec=bash -c \"killall -9 {binary_name} 2>/dev/null || pkill -9 -f {binary_name}\"\n"
                f"Icon=process-stop\n"
            )
            content += action_block

            with open(out_path, 'w', encoding='utf-8') as f:
                f.write(content)
            count += 1
        except Exception:
            pass

print(f"Обработано ярлыков: {count}")
EOF

echo "Обновление системных баз данных ярлыков..."
update-desktop-database ~/.local/share/applications
kbuildsycoca6 2>/dev/null || kbuildsycoca5 2>/dev/null

echo "Успешно! Теперь при клике ПКМ по иконке на панели задач доступно полное закрытие всех процессов приложения."
