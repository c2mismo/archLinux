#!/bin/bash
# Instalamos y preparamos el sistema para el servidor de sonido

# Verificar si no se está ejecutando como root
if [ "$EUID" -eq 0 ]; then
    echo "Por favor, ejecuta este script como un usuario normal, no como root."
    exit 1
fi

# Actualizar la base de datos de paquetes
sudo pacman -Sy

# Función para instalar paquetes si no están instalados
install() {
    local option="$1"
    if ! pacman -Qi "$option" > /dev/null 2>&1; then
        echo "Instalando $option..."
        sudo pacman -S --noconfirm "$option"
    else
        echo "$option ya está instalado."
    fi
}

# Instalación de drivers y herramientas
install "pipewire"        # El servidor de sonido y video.
install "pipewire-alsa"   # Proporciona compatibilidad con ALSA.
install "pipewire-pulse"  # Permite que las aplicaciones que utilizan PulseAudio funcionen con PipeWire.
install "pipewire-jack"   # Permite que las aplicaciones que utilizan JACK funcionen con PipeWire.
install "pavucontrol"     # Interfaz gráfica para controlar el servidor de sonido.

# Verificar y habilitar pipewire.service
if systemctl --user is-active --quiet pipewire.service; then
    echo "pipewire.service ya está activo."
else
    echo "pipewire.service no está activo. Procediendo a habilitar e iniciar..."
    systemctl --user enable pipewire.service
    systemctl --user start pipewire.service
    echo "pipewire.service ha sido habilitado e iniciado."
fi

# Verificar y habilitar pipewire-pulse.service
if systemctl --user is-active --quiet pipewire-pulse.service; then
    echo "pipewire-pulse.service ya está activo."
else
    echo "pipewire-pulse.service no está activo. Procediendo a habilitar e iniciar..."
    systemctl --user enable pipewire-pulse.service
    systemctl --user start pipewire-pulse.service
    echo "pipewire-pulse.service ha sido habilitado e iniciado."
fi

# Ruta de la carpeta de configuración de PipeWire
PIPEWIRE_CONFIG_DIR="$HOME/.config/pipewire"

# Verificar si la carpeta de configuración existe
if [ ! -d "$PIPEWIRE_CONFIG_DIR" ]; then
    echo "La carpeta $PIPEWIRE_CONFIG_DIR no existe. Creando la carpeta..."
    mkdir -p "$PIPEWIRE_CONFIG_DIR"
fi

# Copiar archivos de configuración si no existen
if [ ! -f "$PIPEWIRE_CONFIG_DIR/pipewire.conf" ]; then
    echo "Copiando pipewire.conf a $PIPEWIRE_CONFIG_DIR..."
    cp /etc/pipewire/pipewire.conf "$PIPEWIRE_CONFIG_DIR/"
else
    echo "pipewire.conf ya existe en $PIPEWIRE_CONFIG_DIR."
fi

# Copiar el directorio media-session.d si no existe
if [ ! -d "$PIPEWIRE_CONFIG_DIR/media-session.d" ]; then
    echo "Copiando media-session.d a $PIPEWIRE_CONFIG_DIR..."
    cp -r /etc/pipewire/media-session.d/ "$PIPEWIRE_CONFIG_DIR/"
else
    echo "media-session.d ya existe en $PIPEWIRE_CONFIG_DIR."
fi

# Listar los sinks de PulseAudio
pactl list sinks
