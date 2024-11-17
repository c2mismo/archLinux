#!/bin/bash

if ! pacman -Qi pacman-contrib > /dev/null 2>&1; then
    echo "Instalando pacman-contrib..."
    pacman -Sy
    pacman -S --noconfirm pacman-contrib
    else
    echo "pacman-contrib: Previamente instalando..."
fi
rm temp.sh
