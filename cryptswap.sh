#!/bin/bash

echo "# /dev/mapper/cryptswap LABEL=cryptswap" | tee -a /etc/fstab > /dev/null
echo "/dev/mapper/cryptswap none swap sw 0 0" | tee -a /etc/fstab > /dev/null

[ ! -e /etc/crypttab.initramfs ] && touch /etc/crypttab.initramfs
echo "# Mount swap re-encrypting it with a fresh key each reboot" | tee -a /etc/crypttab.initramfs > /dev/null
echo "cryptswap	UUID=YYY /dev/urandom	swap,cipher=aes-xts-plain64,size=256,sector-size=4096" | tee -a /etc/crypttab.initramfs > /dev/null

[ ! -e /etc/sysctl.d/99-sysctl.conf ] && touch /etc/sysctl.d/99-sysctl.conf
echo "vm.swappiness=10" | tee -a /etc/sysctl.d/99-sysctl.conf > /dev/null
