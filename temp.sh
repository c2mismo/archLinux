#!/bin/bash

# Hacemos una copia de seguridad
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# Obtener la lista de servidores desde el sitio oficial
sudo curl -o /etc/pacman.d/mirrorlist https://archlinux.org/mirrorlist/all/

# Ordenar los Espejos por Velocidad: 
# Arch Linux proporciona una herramienta llamada reflector que puede ayudarte a clasificar los espejos por velocidad.

# Instalamos previamente rsync para que reflector se ejecute correctamente
if ! pacman -Qi rsync > /dev/null 2>&1; then
    echo "Instalando rsync..."
    sudo pacman -Sy --noconfirm rsync
else
    echo "rsync: Previamente instalado."
fi

# Verificar si reflector está instalado
if ! pacman -Qi reflector > /dev/null 2>&1; then
    sudo pacman -Sy --noconfirm reflector
fi

# Aquí, -n 6 indica que deseas mantener los 6 espejos más rápidos
sudo reflector --latest 6 --sort rate --save /etc/pacman.d/mirrorlist

# Sincronizar la base de datos de pacman
sudo pacman -Syy
