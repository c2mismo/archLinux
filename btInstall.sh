#!/bin/bash
# Instalamos y preparamos sistema para el uso de bluetooth

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

pacman -Sy

# Instalación de drivers y herramientas para bluetooth
install() {
    local option="$1"
    if ! pacman -Qi $option > /dev/null 2>&1; then
    sudo pacman -S --noconfirm $option
  fi
}

install "bluez"

install "bluez-utils"

install "bluedevil"

# Verificar y habilitar bluetooth.service
if systemctl --user is-active --quiet bluetooth.service > /dev/null 2>&1; then
    echo "bluetooth.service ya está activo."
else
    echo "bluetooth.service no está activo.\nProcediendo a habilitar e iniciar..."
    systemctl --user enable bluetooth.service > /dev/null 2>&1
    echo "bluetooth.service ha sido habilitado."
fi

echo "Configuracion del bluetooth terminada."

# Limpiar los archivos temporales
sudo rm -f "$0"
exit 0
