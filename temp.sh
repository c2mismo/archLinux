#!/bin/bash

# Crear hook para paccache
HOOK_FILE="/etc/pacman.d/hooks/clean_package_cache.hook"

echo "Creando hook para paccache..."

mkdir -p /etc/pacman.d/hooks

cat > "$HOOK_FILE" << EOF
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Limpiando caché de pacman...
When = PostTransaction
Exec = /usr/bin/paccache -rk1
EOF

echo "Hook de paccache creado."
rm temp.sh
