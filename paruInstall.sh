#!/bin/bash
# Instalamos y preparamos sistema para el procesador i9

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

echo "Instalando y configurando paru..."

# verificamos si se produce un error:
error=0

# Instalar dependencias necesarias
sudo pacman -S --needed --noconfirm base-devel git ranger && \
{ echo "paru y sus dependencias han sido instaladas"; error=0; } || \
{ echo "Error al instalar paru y sus dependencias."; error=1; }

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
if [ $error -eq 0 ]; then
    # Verificar si el directorio de configuración de paru existe
    if [ ! -d $HOME/.config/paru ]; then
        # Crear el directorio de configuración de paru si no existe
        mkdir -p $HOME/.config/paru
        echo "Directorio de configuración de paru creado."
    else
        echo "El directorio de configuración de paru ya existe."
    fi
    if [ -f \"$CONFIG_FILE\" ]; then
        echo "El archivo $CONFIG_FILE ya existe."
    
        # Verificar si el archivo contiene la palabra "keyword"
        if ! grep -q "$keyword" "$CONFIG_FILE"; then
            echo "El archivo no contiene la palabra '$keyword'. Se sobrescribirá el archivo."
            crear_configuracion
            echo "El archivo de configuración ha sido sobrescrito."
            echo "Configuración completada. Paru está listo para usar."
            echo "Recuerda ejecutar 'paru -Syu' para actualizar tu sistema y los paquetes AUR."
        else
            echo "El archivo ya contiene la palabra '$keyword'. No se realizarán cambios."
        fi
    else
        echo "El archivo $CONFIG_FILE no existe. Se creará el archivo."
        crear_configuracion
        echo "El archivo de configuración ha sido creado."
        echo "Configuración completada. Paru está listo para usar."
        echo "Recuerda ejecutar 'paru -Syu' para actualizar tu sistema y los paquetes AUR."
    fi
else
    echo "ERROR: El archivo de configuración no se ha creado: La instalación no se ha realizado con éxito"
fi

sudo rm -f "$0"
