#!/bin/bash
# Instalamos y preparamos sistema para el procesador i9

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

pacman -Sy

pacman -S intel-media-driver mesa xorg-server lib-intel-driver vulkan-intel xorg-xinit

#para monitorear el rendimiento de tu GPU Intel en Wayland
pacman -S intel-gpu-tools

# Herramientas para la gráfica
pacman -S thermald

systemctl enable thermald

pacman -S cpupower

# Configuración solo para Xorg, para Wayland consulta IA:
# "¿Qué herramientas de KDE Plasma puedo usar para ajustar
# el rendimiento y la gestión de energía en Wayland?"

# Creamos una configuración incluye opciones para el método de aceleración gráfico,
# la eliminación de desgarros en la pantalla, el uso de un búfer triple para
# mejorar la fluidez, y la asignación de memoria de video.

# Ruta del archivo de configuración
CONFIG_FILE="/etc/X11/xorg.conf.d/20-intel.conf"
CONFIG_DIR="/etc/X11/xorg.conf.d"

# Función para crear el archivo de configuración
crear_configuracion() {
    cat > "$CONFIG_FILE" << EOF
Section "Device"
    Identifier  "Intel Graphics"
    Driver      "intel"
    
    # Método de aceleración gráfico
    Option      "AccelMethod"  "sna"  # SNA es el método de aceleración recomendado para gráficos Intel

    # Opciones para mejorar la experiencia visual
    Option      "TearFree"     "true"  # Elimina el desgarro de la pantalla
    Option      "TripleBuffer"  "true"  # Mejora la fluidez en la reproducción de video y juegos

    # Asignación de memoria de video
    # La memoria de video se toma de la RAM del sistema
    # usar con precaución hacer pruebas con juegos e IAs.
    # Option      "VideoRam"     "4194304"  # Para 4 GB en KB
    Option      "VideoRam"     "8388608"  # Para 8 GB en KB
    # Option      "VideoRam"     "16777216"  # Para 16 GB en KB
    # Option      "VideoRam"     "31457280"  # Para 30 GB en KB
    # Option      "VideoRam"     "16777216"  # Para 16 GB en KB

    # Configuración de pantalla completa
    Option      "FullScreen"   "true"  # Habilita el modo de pantalla completa para aplicaciones
EndSection
EOF
}

# Verificar si el archivo de configuración existe
if [ -f "$CONFIG_FILE" ]; then
    echo "El archivo $CONFIG_FILE ya existe."

    # Verificar si el archivo contiene la palabra "intel"
    if ! grep -q "intel" "$CONFIG_FILE"; then
        echo "El archivo no contiene la palabra 'intel'. Se sobrescribirá el archivo."
        crear_configuracion
        echo "El archivo de configuración ha sido sobrescrito."
    else
        echo "El archivo ya contiene la palabra 'intel'. No se realizarán cambios."
    fi
else
    echo "El archivo $CONFIG_FILE no existe. Se creará el archivo."
    crear_configuracion
    echo "El archivo de configuración ha sido creado."
fi


echo "Configuracion para i9 terminada."
