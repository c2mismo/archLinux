#!/bin/bash
# Instalamos LXQT mínimo con wailand con qt6 compatible con aplicaciones
# qt5 y X11 usando kwin_wayland compatible con KDE

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

pacman -Sy

# Instalación de LXQT
install() {
    local option="$1"
    if ! pacman -Qi $option > /dev/null 2>&1; then
    pacman -S --noconfirm $option
  fi
}

# Instala el entorno de escritorio LXQt y las bibliotecas necesarias para Qt6 y Qt5.
install "lxqt"

install "qt6"

install "qt5-base"

install "qt5-wayland"

# Instala kwin_wayland, que es el compositor de KDE para Wayland
install "kwin-wayland"

# Para ejecutar aplicaciones que requieren X11
install "xorg-server"

install "qxorg-xwayland"

# Instalamos el gestor de sesión SDDM para iniciar LXQt con KWin en Wayland
install "sddm"

LXQT_CONF="/usr/share/xsessions/lxqt-wayland.desktop"

# Creamos un archivo de sesión para LXQt en Wayland
cat > "$LXQT_CONF" << EOF
[Desktop Entry]
Name=LXQt (Wayland)
Comment=This session starts LXQt on Wayland
Exec=kwin_wayland --session lxqt
TryExec=kwin_wayland
Type=Application
EOF


# Verificamos
sudo systemctl enable sddm.service

rm installLxqt.sh
