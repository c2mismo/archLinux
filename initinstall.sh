#!/bin/bash

# Instalamos el sistema base en /mnt
pacstrap -i /mnt base base-devel fuse linux-zen linux-zen-headers linux-firmware amd-ucode usbutils nano less git btrfs-progs exfat-utils ntfs-3g grub efibootmgr networkmanager wget
# pacstrap -i /mnt base base-devel fuse linux-zen linux-zen-headers linux-firmware intel-ucode usbutils nano less git btrfs-progs exfat-utils ntfs-3g grub efibootmgr networkmanager wget


# Limpiar los archivos temporales
sudo rm -f "$0"
