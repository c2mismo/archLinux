#!/bin/bash
# Instalamos LXQt mínimo con Wayland con Qt6 compatible con aplicaciones
# Qt5 y X11 usando kwin_wayland compatible con KDE

# Verifica si paru está instalado
if ! command -v paru &> /dev/null; then
  echo "El paquete 'paru' no está instalado. Por favor, instálalo antes de ejecutar este script."
  exit 1
fi

# Verificar si no se está ejecutando como root
if [ "$EUID" -eq 0 ]; then
    echo "Por favor, ejecuta este script como un usuario normal, no como root."
    read -p "Introduce el nombre de usuario: " usuario
    echo "Cambiando a usuario '$usuario'..."
    exec sudo -u "$usuario" "$0" "$@"  # Reinicia el script como el usuario especificado
    exit 1
fi

# Actualiza la base de datos de paquetes
paru -Sy

# Función para instalar paquetes
install() {
    local option="$1"
    if ! paru -Qi "$option" > /dev/null 2>&1; then
        paru -S --noconfirm "$option"
    fi
}

# Instala el entorno de escritorio LXQt y las bibliotecas necesarias para Qt6 y Qt5.
install "lxqt"
install "qt6"
install "qt5-base"
install "qt5-wayland"

# Instala kwin_wayland, que es el compositor de KDE para Wayland
install "xwayland-run-kwin"

# Para ejecutar aplicaciones que requieren X11
install "xorg-server"
install "xorg-xwayland"

# Instalamos el gestor de sesión SDDM para iniciar LXQt con KWin en Wayland
install "sddm"

LXQT_CONF="/usr/share/xsessions/lxqt-wayland.desktop"

# Creamos un archivo de sesión para LXQt en Wayland
sudo bash -c "cat > \"$LXQT_CONF\" << EOF
[Desktop Entry]
Name=LXQt (Wayland)
Comment=This session starts LXQt on Wayland
Exec=xwayland-run-kwin --session lxqt
TryExec=xwayland-run-kwin
Type=Application
EOF"

# Habilitamos el servicio SDDM
sudo systemctl enable sddm.service

# Mensaje de finalización
echo "Instalación completada. Puedes iniciar sesión en LXQt (Wayland) desde el gestor de sesiones."

rm install_lxqt.sh
