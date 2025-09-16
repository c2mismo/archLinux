#!/bin/bash
# Configuramos pacman para:
# Usar salida con color"
# Usar 5 descargas paralelas"
# Mantener solo paquetes instalados en la caché"
# Guardar solo una versión antigua de cada paquete (incluyendo los desinstalados)"
# Usar el repositorio multilib"

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi


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
# Configurar CleanMethod
update_option "CleanMethod = KeepInstalled"

# Configurar Color
update_option "Color"

# Configurar ParallelDownloads
update_option "ParallelDownloads = 5"

# Función para descomentar una opción con dos líneas
update_repo() {
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
        echo "Descomentado $section en $pacman_conf"

        # Verificar si la línea siguiente existe y contiene el valor de $include_line
        if [ "$((line_number + 1))" -le "$(wc -l < "$pacman_conf")" ]; then
            local next_line=$(sed -n "$((line_number + 1))p" "$pacman_conf")
            if [[ "$next_line" == *"$include_line"* ]]; then
                sed -i "$((line_number + 1))s|^#||" "$pacman_conf"  # Eliminar el # de Include
                echo "Descomentado $include_line en $pacman_conf"
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
update_repo "#\[multilib\]" "#Include = /etc/pacman.d/mirrorlist"

# Habilitar repositorio community
update_repo "#\[community\]" "#Include = /etc/pacman.d/mirrorlist"

# Instalar pacman-contrib si no está instalado
if ! pacman -Qi pacman-contrib > /dev/null 2>&1; then
    echo "Instalando pacman-contrib..."
    pacman -Sy
    pacman -S --noconfirm pacman-contrib
    else
    echo "pacman-contrib: Previamente instalando..."
fi


# Crear carpeta hook para paccache
HOOK_DIR="/etc/pacman.d/hooks"

# Verificar si la carpeta de configuración existe
if [ ! -d "$HOOK_DIR" ]; then
    echo "La carpeta $HOOK_DIR no existe. Creando la carpeta..."
    mkdir -p "$HOOK_DIR"
fi

# Crear hook para paccache
HOOK_FILE="/etc/pacman.d/hooks/clean_package_cache.hook"

echo "Creando hook para paccache..."

cat > "$HOOK_FILE" << EOF
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Limpiando caché de pacman...
When = PostTransaction
Exec = /usr/bin/paccache -rk1
EOF

echo "Hook de paccache creado."

# Limpiar la caché actual
echo "Limpiando la caché de pacman..."
pacman -Sc --noconfirm
paccache -rk1

echo "Configuración completada. Pacman ahora está configurado para:"
echo "  - Usar salida con color"
echo "  - Usar 5 descargas paralelas"
echo "  - Mantener solo paquetes instalados en la caché"
echo "  - Guardar solo una versión antigua de cada paquete (incluyendo los desinstalados)"
echo "  - Usar los repositorios multilib y community"
echo ""
echo "Recuerda actualizar los repositorio "pacman -Sy" y"
echo "deberás reiniciar cualquier terminal abierta para que los cambios surtan efecto."

# Limpiar los archivos temporales
sudo rm -f "$0"
exit 0
