#!/bin/bash

# Instalando y configurando PARU

# Verificar si el script se está ejecutando como root
if [ "$EUID" -eq 0 ]; then
    echo "Por favor, ejecuta este script como un usuario normal, no como root."
    read -p "Introduce el nombre de usuario: " usuario
    echo "Cambiando a usuario '$usuario'..."
    # 2. Cambiar al directorio home del usuario especificado
    home_dir=$(getent passwd "$usuario" | cut -d: -f6)
    if [ -d "$home_dir" ]; then
        cd "$home_dir" || exit 1  # Cambia al directorio home del usuario
    else
        echo "Error: El directorio home para el usuario '$usuario' no existe."
        exit 1
    fi

    exec sudo -u "$usuario" "$0" "$@"
    exit 1
fi




sudo rm -f "$0"
