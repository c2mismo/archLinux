#!/bin/bash

# Creamos el fstab para el montaje automático al inicio del sistema

genfstab -U /mnt >> /mnt/etc/fstab && echo "fstab creado"

cat /mnt/etc/fstab

# Limpiar los archivos temporales
sudo rm -f "$0"
