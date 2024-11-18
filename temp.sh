#!/bin/bash

# Hacemos una copia de seguridad
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# descargamos una lista completa de los servidores oficiales de arch
if [ -e /etc/pacman.d/mirrorlist_all ]; then
  cp /etc/pacman.d/mirrorlist_all /etc/pacman.d/mirrorlist_all.backup
fi
curl -o /etc/pacman.d/mirrorlist_all https://archlinux.org/mirrorlist/all/

# Podriamos filtrar los servidores solo para los de españa
if [ -e /etc/pacman.d/mirrorlist_es ]; then
  cp /etc/pacman.d/mirrorlist_es /etc/pacman.d/mirrorlist_es.backup
fi
sed -n '/## Spain/,/^$/p' /etc/pacman.d/mirrorlist_all > /etc/pacman.d/mirrorlist_es



# Ordenar los Espejos por Velocidad: 
# Arch Linux proporciona una herramienta llamada
# rankmirrors que puede ayudarte a clasificar los espejos por velocidad.
# es uno de los paquetes del contenedor pacman-contrib

if ! pacman -Qi pacman-contrib > /dev/null 2>&1; then
    echo "Instalando pacman-contrib..."
    pacman -Sy
    pacman -S --noconfirm pacman-contrib
    else
    echo "pacman-contrib: Previamente instalando..."
fi

# Aquí, -n 6 indica que deseas mantener los 6 espejos más rápido
rankmirrors -n 6 /etc/pacman.d/mirrorlist_all | sudo tee /etc/pacman.d/mirrorlist

# seguramente si es eficiente el programa usemos del all el mas rapido.
