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

# verificamos si se produce un error:
error=0

# Instalar dependencias necesarias
sudo pacman -S --needed --noconfirm base-devel git ranger && \
{ echo "Instaladas las dependencias necesarias para instalar paru"; error=0; } || \
{ echo "Error al instalar las dependencias."; error=1; }

# Verificar si paru no está instalado y si no hubo errores
if ! pacman -Qi paru > /dev/null 2>&1 && [ $error -eq 0 ]; then
    echo "Instalando paru..."
    # Accedemos al directorio
    cd paru || { error=1; echo "Error al acceder al directorio de paru. Error = $error"; }
    # Compilar e instalar paru
    makepkg -si --noconfirm || { error=1; echo "Error al compilar paru. Error = $error"; }
    # Volver al directorio anterior y limpiar
    cd .. || { error=1; echo "Error al volver al directorio anterior. Error = $error"; }
    rm -rf paru || { error=1; echo "Error al limpiar el repositorio de paru. Error = $error"; }

    if [ $error -eq 0 ]; then
        echo "Paru ha sido instalado."
    fi
fi


# Verificar si el directorio de configuración de paru existe
if [ ! -d ~/.config/paru ]; then
    # Crear el directorio de configuración de paru si no existe
    mkdir -p ~/.config/paru
    echo "Directorio de configuración de paru creado."
else
    echo "El directorio de configuración de paru ya existe."
fi

CONFIG_FILE="$HOME/.config/paru/paru.conf"

keyword="ranger"

# Función para crear el archivo de configuración
crear_configuracion() {
    cat > "$CONFIG_FILE" << EOF
[options]
BottomUp
SudoLoop
CleanAfter
UpgradeMenu
NewsOnUpgrade
RemoveMake
BatchInstall
UseAsk
CombinedUpgrade
#SkipReview

[bin]
FileManager = ranger
EOF
}

# Verificar si no ha habido ningún error y
# si el archivo de configuración no existe o no contiene la palabra clave
if [ -f "$CONFIG_FILE" ] && [ $error -eq 0 ]; then
    echo "El archivo $CONFIG_FILE ya existe."

    # Verificar si el archivo contiene la palabra "keyword"
    if ! grep -q "$keyword" "$CONFIG_FILE"; then
        echo "El archivo no contiene la palabra '$keyword'. Se sobrescribirá el archivo."
        crear_configuracion
        echo "El archivo de configuración ha sido sobrescrito."
    else
        echo "El archivo ya contiene la palabra '$keyword'. No se realizarán cambios."
    fi
else
    echo "El archivo $CONFIG_FILE no existe. Se creará el archivo."
    crear_configuracion
    echo "El archivo de configuración ha sido creado."
fi

echo "Configuración completada. Paru está listo para usar."
echo "Recuerda ejecutar 'paru -Syu' para actualizar tu sistema y los paquetes AUR."

sudo rm -f "$0"
