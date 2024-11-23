#!/bin/bash

# Verificamos si se produce un error:
flag_error=0
# Mensaje del error:
error=""

# Instalar dependencias necesarias
echo "Instalando dependencias de paru"
sudo pacman -S --needed --noconfirm base-devel git ranger && \
{ flag_error=0; error="Instaladas las dependencias necesarias para instalar paru"; } || \
{ flag_error=1; error="Error al instalar las dependencias."; }

read -p "Para configurar paru introduce nombre de usuario: " usuario
echo "Cambiando a usuario '$usuario'..."
# 2. Cambiar al directorio home del usuario especificado
home_dir=$(getent passwd "$usuario" | cut -d: -f6)
if [ -d "$home_dir" ]; then
    cd "$home_dir" || exit 1  # Cambia al directorio home del usuario
else
    echo "El directorio home para el usuario '$usuario' no existe."
    exit 1
fi

# Ejecutar el script como el usuario especificado
exec sudo -u "$usuario" "$0" "$@"
exit 1

echo "Configurando paru como: $usuario en $home_dir"

# Verificar si paru no está instalado y si no hubo errores
if ! pacman -Qi paru > /dev/null 2>&1 && [ $flag_error -eq 0 ]; then
    echo "Instalando paru previamente no instalado..."
    # Clonar el repositorio de paru
    git clone https://aur.archlinux.org/paru.git || { flag_error=1; error="Error al clonar el repositorio de paru."; }
    # Accedemos al directorio
    cd paru || { flag_error=1; error="Error al acceder al directorio de paru."; }
    # Compilar e instalar paru
    makepkg -si --noconfirm || { flag_error=1; error="Error al compilar paru."; }
    # Volver al directorio anterior y limpiar
    cd .. || { flag_error=1; error="Error al volver al directorio anterior."; }
    rmsudo rm -f "$0" -rf paru || { flag_error=1; error="Error al limpiar el repositorio de paru."; }

    if [ $flag_error -eq 0 ]; then
        echo "Paru ha sido instalado correctamente."
        echo "Continuamos con la configuración de paru."
    fi
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
if [ $flag_error -eq 0 ]; then
    # Verificar si el directorio de configuración de paru existe
    if [ ! -d "$HOME/.config/paru" ]; then
        # Crear el directorio de configuración de paru si no existe
        mkdir -p "$HOME/.config/paru"
        echo "Directorio de configuración de paru creado."
    else
        echo "El directorio de configuración de paru existe."
    fi

    if [ -f "$CONFIG_FILE" ]; then
        echo "El archivo $CONFIG_FILE existe."

        # Verificar si el archivo contiene la palabra "keyword"
        if ! grep -q "$keyword" "$CONFIG_FILE"; then
            echo "El archivo no contiene la palabra '$keyword'. Sobrescribiendo archivo."
            crear_configuracion
            echo "El archivo de configuración se ha sobrescrito. Configuración completada."
        else
            echo "El archivo contiene la palabra '$keyword'. No se realizarán cambios."
        fi
    else
        echo "El archivo $CONFIG_FILE no existe. Creando el archivo."
        crear_configuracion
        echo "El archivo de configuración ha sido creado. Configuración completada."
    fi
else
    error="El archivo de configuración no se ha creado: La compilación no se ha realizado con éxito"
fi

if [ $flag_error -eq 0 ]; then
    paru -Syy && \
    echo -e "Repositorios oficiales y AUR actualizados con paru." || \
    error="Repositorios oficiales y AUR no actualizados con paru."
fi

if [ "$flag_error" -ne 0 ]; then
    echo "ERROR: $error."
    exit $flag_error
else
    echo "Correcto."
fi
