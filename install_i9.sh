#!/bin/bash
# Instalamos y preparamos sistema para el procesador i9

pacman -Sy

pacman -S mesa vulkan-intel

pacman -S thermald

systemctl enable thermald
# no esta aún levantado reinicia antes

pacman -S htop intel-gpu-tools

pacman -S cpupower


mkdir -p /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/20-intel.conf << EOF
Section "Device"
    Identifier  "Intel Graphics"
    Driver      "intel"
    Option      "AccelMethod"  "sna"
    Option      "TearFree"     "true"
EndSection
EOF

sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="quiet elevator=bfq"/' /etc/default/grub

echo "Configuracion para i9 terminada."
