#!/bin/bash

# Instalamos el sistema base en /mnt
pacstrap -i /mnt base base-devel fuse linux-zen linux-zen-headers linux-firmware intel-ucode usbutils nano less git btrfs-progs exfat-utils ntfs-3g xfsprogs grub efibootmgr networkmanager wget

# Limpiar los archivos temporales
sudo rm -f "$0"
