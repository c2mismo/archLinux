#!/bin/bash

echo "Configurando pacman..."

# Ruta al archivo de configuración de pacman
PACMAN_CONF="/etc/pacman.conf"

# Función para agregar o actualizar una opción en pacman.conf
update_option() {
    local option="$1"
    local value="$2"
    if grep -q "^#*$option" "$PACMAN_CONF"; then
        sudo sed -i "s/^#*$option.*/$option = $value/" "$PACMAN_CONF"
    else
        echo "$option = $value" | sudo tee -a "$PACMAN_CONF" > /dev/null
    fi
}

# Configurar Color
update_option "Color" ""

# Configurar ParallelDownloads
update_option "ParallelDownloads" "5"

# Configurar CleanMethod
update_option "CleanMethod" "KeepInstalled"

# Habilitar repositorio multilib
if ! grep -q "^\[multilib\]" "$PACMAN_CONF"; then
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a "$PACMAN_CONF" > /dev/null
    echo "Repositorio multilib habilitado."
else
    echo "El repositorio multilib ya está habilitado."
fi

echo "Configuración de pacman actualizada."

# Instalar pacman-contrib si no está instalado
if ! pacman -Qi pacman-contrib > /dev/null 2>&1; then
    echo "Instalando pacman-contrib..."
    sudo pacman -S --noconfirm pacman-contrib
fi

# Crear hook para paccache
HOOK_FILE="/etc/pacman.d/hooks/clean_package_cache.hook"

echo "Creando hook para paccache..."

sudo tee "$HOOK_FILE" > /dev/null <<EOL
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
EOL

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

echo "Recuerda reiniciar cualquier terminal abierta para que los cambios surtan efecto."
