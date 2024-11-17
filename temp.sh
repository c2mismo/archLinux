#!/bin/bash


echo "Configurando pacman..."

# Ruta al archivo de configuración de pacman
PACMAN_CONF="/etc/pacman.conf"

# Función para descomentar una opción con dos líneas
update_multilib() {
    local section="$1"
    local include_line="$2"
    local pacman_conf="$PACMAN_CONF"

    # Verificar si la sección [multilib] existe
    if grep -q "$section" "$pacman_conf"; then
        echo "Encontrado $section en $pacman_conf"

        # Obtener el número de línea de la sección [multilib]
        local line_number=$(grep -n "$section" "$pacman_conf" | cut -d: -f1)

        # Modificar la línea de la sección [multilib]
        sed -i "${line_number}s|^#||" "$pacman_conf"  # Eliminar el # de la sección

        # Verificar si la línea siguiente existe y contiene el valor de $include_line
        if [ "$((line_number + 1))" -le "$(wc -l < "$pacman_conf")" ]; then
            local next_line=$(sed -n "$((line_number + 1))p" "$pacman_conf")
            if [[ "$next_line" == *"$include_line"* ]]; then
                sed -i "$((line_number + 1))s|^#||" "$pacman_conf"  # Eliminar el # de Include
                echo "Configurado $include_line en $pacman_conf"
            else
                echo "ERROR: La línea siguiente a $section no contiene el valor esperado: $include_line"
            fi
        else
            echo "ERROR: No se puede modificar la línea siguiente a $section porque no existe."
        fi
    else
        echo "ERROR: No se ha encontrado $section en $pacman_conf"
    fi
}

# Habilitar repositorio multilib
update_multilib "#[multilib]" "#Include = /etc/pacman.d/mirrorlist"

rm temp.sh
