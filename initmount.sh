#!/bin/bash
# Montamos las particiones iniciales

mount /dev/mapper/cryptarch /mnt && echo "cryptroot montado"

mkdir /mnt/boot && echo "Directorio /boot creado"
mount /dev/nvme0n1p5 /mnt/boot && echo "boot montado"

mkdir /mnt/boot/efi && echo "Directorio /boot/efi creado"
mount /dev/nvme0n1p1 /mnt/boot/efi && echo "efi montado"

# mkdir /mnt/srv && mkdir /mnt/srv/samba && echo "Directorio /srv/samba creado"
# mount /dev/nvme0n1p6 /mnt/srv/samba && echo "samba montado"

# Limpiar los archivos temporales
sudo rm -f "$0"
