#!/bin/bash
# Instalamos LXQt mínimo con Wayland con Qt6 compatible con aplicaciones
# Qt5 y X11 usando kwin_wayland compatible con KDE

# Verifica si paru está instalado
if ! command -v paru &> /dev/null; then
  echo "El paquete 'paru' no está instalado. Por favor, instálalo antes de ejecutar este script."
  exit 1
fi

# Verificamos si se a introducido un nombre de usuario correcto
# y lo mantenemos accesible en el reinicio del script
checked_user="/tmp/checked_user.tmp"

# Reiniciando script como usuario
if [ ! -f "$checked_user" ]; then
    read -p "Para configurar lxqt introduce nombre de usuario: " usuario
    echo "Cambiando a usuario '$usuario'..." 
    home_dir=$(getent passwd "$usuario" | cut -d: -f6)
    if [ -d "$home_dir" ]; then
        cd "$home_dir" # Cambiar al directorio home del usuario especificado
        touch "$checked_user" # Ejecutar el script como el usuario especificado
        exec sudo -u "$usuario" "$0" "$@" || \
        { echo "No es posible ejecutar el script como el usuario $usuario."; sudo rm -f "$checked_user"; exit 1; }
    else
        echo "El directorio home para el usuario '$usuario' no existe."
        usuario=""
        exit 1
    fi
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
kwin
~/.xinitrc
exec kwin_wayland
# install "qt6"
# install "qt5-base"
# install "qt5-wayland"
# install "qt5-declarative"

libstatgrab libsysstat lm_sensors network-manager-applet oxygen-icons

# Instala kwin_wayland, que es el compositor de KDE para Wayland ya no necesario
# install "xwayland-run-kwin"

# si falla el arranque de wayland intentar instalar
# lxqt-wayland-session

# Para ejecutar aplicaciones que requieren X11
# install "xorg-server"
# install "xorg-xwayland"

# LXQT_CONF="/usr/share/xsessions/lxqt-wayland.desktop"

# Creamos un archivo de sesión para LXQt en Wayland
# if [ ! -f "$LXQT_CONF" ]; then
#    sudo bash -c "cat > \"$LXQT_CONF\" << EOF
# [Desktop Entry]
# Name=LXQt (Wayland)
# Comment=This session starts LXQt on Wayland
# Exec=startlxqtwayland
# TryExec=startlxqtwayland
# Type=Application
# EOF"
# else
#    echo "El archivo de sesión $LXQT_CONF no ha sido creado:"
#    echo "El archivo de sesión ya existe."
# fi


# Mensaje de finalización
echo "Instalación completada. Puedes iniciar sesión en LXQt (Wayland) desde el gestor de sesiones."

# Limpiar los archivos temporales
sudo rm -f "$checked_user"
sudo rm -f "$0"
