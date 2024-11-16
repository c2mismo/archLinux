echo "# /dev/mapper/cryptswap LABEL=cryptswap" | sudo tee -a /etc/fstab
echo "/dev/mapper/cryptswap none swap sw 0 0" | sudo tee -a /etc/fstab

[ ! -e /etc/crypttab.initramfs ] && sudo touch /etc/crypttab.initramfs
echo "# Mount swap re-encrypting it with a fresh key each reboot" | sudo tee -a /etc/crypttab.initramfs
echo "cryptswap	UUID=YYY /dev/urandom	swap,cipher=aes-xts-plain64,size=256,sector-size=4096" | sudo tee -a /etc/crypttab.initramfs

[ ! -e /etc/sysctl.d/99-sysctl.conf ] && sudotouch /etc/sysctl.d/99-sysctl.conf
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.d/99-sysctl.conf
