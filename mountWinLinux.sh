#!/bin/bash
# Montamos la particion compartida con windows

mkdir /run/media/c2mismo && mkdir /run/media/c2mismo/WinLinux && echo "Directorio /run/media/c2mismo/WinLinux creado" || echo "ERROR: Directorio /run/media/c2mismo/WinLinux creado."
mount /dev/nvme0n1p6 /run/media/c2mismo/WinLinux && echo "WinLinux montado" || echo "ERROR: WinLinux no montado."

# Limpiar los archivos temporales
sudo rm -f "$0"
