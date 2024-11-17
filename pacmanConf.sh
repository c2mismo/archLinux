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

# Configurar CleanMethod
update_option "CleanMethod = KeepInstalled"

# Configurar Color
update_option "Color"

# Configurar ParallelDownloads
update_option "ParallelDownloads = 5"

# Habilitar repositorio multilib
update_option_silent "\[multilib\]"

# Función para agregar o actualizar una opción en pacman.conf
update_option() {
    local option="$1"
    if grep -q "^# $option" "$PACMAN_CONF"; then
        echo "Encontrado #$option en $PACMAN_CONF"
        sudo sed -i "s/^# $option/$option/" $PACMAN_CONF
        echo "Configurado #$option en $PACMAN_CONF"
    else
        echo "ERROR: No se ha encontrado #$option en $PACMAN_CONF"
    fi
}
# Función para agregar o actualizar una opción en pacman.conf con dos líneas
update_option_silent() {
    local option="$1"
    if grep -q "^# $option" "$PACMAN_CONF"; then
        sudo sed -i "s/^# $option/$option/" $PACMAN_CONF
        update_option "Include = /etc/pacman.d/mirrorlist"
    else
        echo "ERROR: No se ha encontrado #$option en $PACMAN_CONF"
    fi
}

echo "Configuración de pacman actualizada."

# Instalar pacman-contrib si no está instalado
if ! pacman -Qi pacman-contrib > /dev/null 2>&1; then
    echo "Instalando pacman-contrib..."
    sudo pacman -S --noconfirm pacman-contrib
fi

# Crear hook para paccache
HOOK_FILE="/etc/pacman.d/hooks/clean_package_cache.hook"

echo "Creando hook para paccache..."

mkdir -p /etc/pacman.d/hooks

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
sudo pacman -Sc --noconfirm
sudo paccache -rk1

echo "Configuración completada. Pacman ahora está configurado para:"
echo "  - Usar salida con color"
echo "  - Usar 5 descargas paralelas"
echo "  - Mantener solo paquetes instalados en la caché"
echo "  - Guardar solo una versión antigua de cada paquete (incluyendo los desinstalados)"
echo "  - Usar el repositorio multilib"
echo ""
echo "Recuerda actualizar los repositorio "pacman -Sy" y"
echo "deberás reiniciar cualquier terminal abierta para que los cambios surtan efecto."

rm pacmanConf.sh
