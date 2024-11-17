#!/bin/bash


echo "Configurando pacman..."

# Ruta al archivo de configuración de pacman
PACMAN_CONF="/etc/pacman.conf"

# Función para agregar o actualizar una opción en pacman.conf
update_option() {
    local option="$1"
    if grep -q "^#$option" "$PACMAN_CONF"; then
        echo "Encontrado #$option en $PACMAN_CONF"
        sed -i "s/^#$option/$option/" $PACMAN_CONF
        echo "Configurado #$option en $PACMAN_CONF"
    else
        echo "ERROR: No se ha encontrado #$option en $PACMAN_CONF"
    fi
}
# Función para agregar o actualizar una opción en pacman.conf con dos líneas
update_option_silent() {
    local option="$1"
    if grep -q "^#$option" "$PACMAN_CONF"; then
        sed -i "s/^#$option/$option/" $PACMAN_CONF
        update_option "Include = /etc/pacman.d/mirrorlist"
    else
        echo "ERROR: No se ha encontrado #$option en $PACMAN_CONF"
    fi
}

# Configurar CleanMethod
update_option "CleanMethod = KeepInstalled"

# Configurar Color
update_option "Color"

# Configurar ParallelDownloads
update_option "ParallelDownloads = 5"

# Habilitar repositorio multilib
update_option_silent "\[multilib\]"

rm temp.sh
