#!/bin/bash
# Sincronizamos relog & configuramos red
# Instalamos gestor de RED NetworkManager con el backend de
# iwd que mejora la seguridad y la eficiencia

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Sincronizando Relog
timedatectl set-ntp true && /
timedatectl show-timesync && /
echo "Relog del sistema sincronizado."

pacman -Sy

# Instalación de drivers y herramientas para Intel
install() {
    local option="$1"
    if ! pacman -Qi $option > /dev/null 2>&1; then
    sudo pacman -S --noconfirm $option
  fi
}

install "samba"

install "cifs-utils"

install "networkmanager"

install "iwd"

# Archivo configuración de NetworkManager
NM_CONF="/etc/NetworkManager/NetworkManager.conf"

cat >> "$NM_CONF" << EOF

[device]
wifi.backend=iwd
EOF

echo "Configuracion NetworkManager con el backend de iwd, finalizado."

# Verificar si NetworkManager está habilitado antes de habilitar el servicio
if systemctl is-enabled NetworkManager &> /dev/null; then
    echo "El servicio NetworkManager ya está habilitado."
else
    sudo systemctl enable NetworkManager
    echo "NetworkManager ha sido habilitado para iniciar en el arranque."
fi

# Limpiar los archivos temporales
sudo rm -f "$0"
exit 0
