#!/bin/bash

# 1. Guardar el directorio actual
directorio_actual=$(pwd)

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

    # 3. Reinicia el script como el usuario especificado
    exec sudo -u "$usuario" "$0" "$@"
    exit 1
fi

# 4. Aquí va el resto del script que se ejecutará como el usuario normal
echo "Ejecutando el resto del script como el usuario normal..."

# (Aquí puedes agregar el código que deseas ejecutar como el usuario especificado)

# 5. Devolver al directorio en el que nos encontrábamos antes de iniciar el script
cd "$directorio_actual" || exit 1  # Regresar al directorio original
echo "Regresando al directorio original: $directorio_actual"


rm temp.sh
