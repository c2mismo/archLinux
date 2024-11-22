#!/bin/bash

echo "Instalando y configurando paru..."

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


verificamos si se produce un error:
error=0

# Instalar dependencias necesarias
sudo pacman -S --needed --noconfirm base-devel git ranger && \
{ echo "Instaladas las dependencias necesarias para instalar paru"; error=0; } || \
{ echo "Error al instalar las dependencias."; error=1; }

if ! pacman -Qi paru > /dev/null 2>&1 && [ $error -eq 0 ]; then
  echo "Instalando paru..."
  # Accedemos al directorio
  cd paru || { echo "Error al volver al directorio anterioru."; error=1; } && \
  # Compilar e instalar paru
  makepkg -si --noconfirm || { echo "Error al compilar paru."; error=1; } && \
  # Volver al directorio anterior y limpiar
  cd ..
  rm -rf paru || { echo "Error al limpiar el repositorio de paru."; error=1; } && \
  echo "Paru ha sido instalado."
fi

# Verificar si el directorio de configuración de paru existe
if [ ! -d ~/.config/paru ]; then
    # Crear el directorio de configuración de paru si no existe
    mkdir -p ~/.config/paru
    echo "Directorio de configuración de paru creado."
else
    echo "El directorio de configuración de paru ya existe."
fi


sudo rm -f "$0"
