#!/bin/bash
# Instalamos y configuramos paru
# un ayudante de AUR (Arch User Repository) para Arch Linux y sus derivados.

echo "Instalando paru..."

# verificamos si se produce un error:
flag_error=0

# Instalar dependencias necesarias
pacman -S --needed --noconfirm base-devel git ranger paru && \
{ echo "paru: Instalado y sus dependencias necesarias."; flag_error=0; } || \
{ echo "Error al instalar paru y sus dependencias."; flag_error=1; }


read -p "Para configurar paru introduce nombre de usuario: " usuario
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


echo "Configurando paru..."

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
if [ $flag_error -eq 0 ]; then
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
            echo "Configuración completada. Paru está listo para actualizar."
        else
            echo "WARNING: El archivo ya contiene la palabra '$keyword'. El archivo de configuración no ha sido modificado."
        fi
    else
        echo "El archivo $CONFIG_FILE no existe. Se creará el archivo."
        crear_configuracion
        echo "El archivo de configuración ha sido creado."
        echo "Configuración completada. Paru está listo para actualizar."
    fi
else
    echo "ERROR: El archivo de configuración no se ha creado: La instalación no se ha realizado con éxito"
fi

paru -Syy && \
echo "Repositorios oficiales y AUR actualizados con paru." || \
echo "ERROR: Repositorios oficiales y AUR no actualizados con paru."

sudo rm -f "$0"
