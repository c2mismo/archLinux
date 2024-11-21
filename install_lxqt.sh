#!/bin/bash
# Instalamos LXQt mínimo con Wayland con Qt6 compatible con aplicaciones
# Qt5 y X11 usando kwin_wayland compatible con KDE

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Actualiza la base de datos de paquetes
pacman -Sy

# Función para instalar paquetes
install() {
    local option="$1"
    if ! pacman -Qi "$option" > /dev/null 2>&1; then
        pacman -S --noconfirm "$option"
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
install "xorg-xwayland"

# Instalamos el gestor de sesión SDDM para iniciar LXQt con KWin en Wayland
install "sddm"

# LXQT_CONF="/usr/share/xsessions/lxqt-wayland.desktop"

# Creamos un archivo de sesión para LXQt en Wayland
#cat > "$LXQT_CONF" << EOF
#[Desktop Entry]
#Name=LXQt (Wayland)
#Comment=This session starts LXQt on Wayland
#Exec=kwin_wayland --session lxqt
#TryExec=kwin_wayland
#Type=Application
#EOF

# Habilitamos el servicio SDDM
#systemctl enable sddm.service

# Mensaje de finalización
echo "Instalación completada. Puedes iniciar sesión en LXQt (Wayland) desde el gestor de sesiones."

rm installLxqt.sh
