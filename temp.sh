#!/bin/bash

# Limpiar la caché actual
echo "Limpiando la caché de pacman..."
pacman -Sc --noconfirm
paccache -rk1
rm temp.sh
