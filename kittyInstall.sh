#!/bin/bash
# Instalamos y configuramos kitty
# por seguridad será configurado por usuario
# cada usuario nuevo de ser configurado

# Verificamos si se a introducido un nombre de usuario correcto
# y lo mantenemos accesible en el reinicio del script
checked_user="/tmp/checked_user.tmp"

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
install "kitty"

# Reiniciando script como usuario
if [ ! -f "$checked_user" ]; then
    read -p "Para configurar pipewire introduce nombre de usuario: " usuario
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



# Ruta de la carpeta de configuración de kitty
KITTY_CONFIG_DIR="$HOME/.config/kitty"

# Verificar si la carpeta de configuración existe
if [ ! -d "$KITTY_CONFIG_DIR" ]; then
    echo "La carpeta $KITTY_CONFIG_DIR no existe. Creando la carpeta..."
    mkdir -p "$KITTY_CONFIG_DIR"
fi

# Crear el archivo de configuracion de kitty
KITTY_CONFIG="$HOME/.config/kitty/kitty.conf"

cat > "$KITTY_CONFIG" << EOF
# Configuración personalizada.
# Warning: No incluir comentarios el la misma línea de la configuración, da error.

# Incluye el archivo colors.conf en kitty.conf y configura las fuentes:
include solarized_dark.conf
# Establece la familia de fuentes
font_family monospace
# Selección automática de fuente en negrita
bold_font auto
# Selección automática de fuente en cursiva
italic_font auto
# Selección automática de fuente en negrita cursiv
bold_italic_font autoa
# Tamaño de la fuente
font_size 14.0
# Espaciado entre letras
font_spacing 0.5
# Espaciado entre líneas
line_height 1.2
# Suavizado de texto
antialiasing true
# Número de líneas en el historial
scrollback_lines 2000

# Tipo de shell por defecto bash, zsh, etc
# shell zsh

# Configuración para ocultar el cursor tras segundos de inactividad:
mouse_hide_wait 3.0

# Configuración para la detección automática de URLs:

# Habilita la detección automática de URLs
detect_urls yes
# Color de las URLs
url_color #0087bd
# Estilo de subrayado de las URLs
url_style double
# Navegador predeterminado para abrir URLs
open_url_with default
# Prefijos de URLs a detectar
url_prefixes ftp ssh http https git irc sftp
# Muestra los objetivos de los hipervínculos
show_hyperlink_targets yes

# Configura el manejo de ventanas similar a Tmux:

# Bordes mínimos
draw_minimal_borders yes
# Estrategia de colocación de ventanas
placement_strategy center
# Color del borde de la ventana activa
active_border_color #808000
# Transparencia del texto en ventanas inactivas
inactive_text_alpha 0.5

# Configuración avanzada de pestañas similar a tmux:

# Pestañas en la parte inferior
tab_bar_edge bottom
# Margen entre pestañas
tab_bar_margin_with 0.1
# Estilo de las pestañas
tab_bar_style powerline
# Mínimo de pestañas
tab_bar_min_tabs 1
# Fondo de pestañas inactivas
inactive_tab_background #e06c75
# Color de texto de pestañas inactivas
inactive_tab_foreground #000000
# Fondo de pestañas activas
active_tab_background #98c379
# Color de borde de notificación
bell_border_color #ff5a00
# Separador entre pestañas
tab_separator " |"
# Sin símbolo de actividad
tab_activity_symbol none
# Color del margen de la barra de pestañas
tab_bar_margin_color #FFFF00
# Desenfoque del fondo me da error y consume recursos GPU
# background_blur 0.6

# Aceleeracion GPU

enable_audio_bell no

# Atajos de teclado:

map ctrl+shift+enter new_window_with_cwd
map ctrl+shift+t new_tab
map ctrl+alt+t set_tab_title
map ctrl+shift+w close_window
map ctrl+left neighboring_window left
map ctrl+right neighboring_window right
map ctrl+up neighboring_window up
map ctrl+down neighboring_window down
map ctrl+shift+l clear_terminal to_cursor_active
map ctrl+shift+up resize_window taller 5
map ctrl+shift+down resize_window shorter 5
map ctrl+shift+left resize_window wider 5
map ctrl+shift+right resize_window narrower 5
EOF

# Crear el archivo de configuracion do los colores de kitty
KITTY_COLORS="$HOME/.config/kitty/solarized_dark.conf"

cat > "$KITTY_COLORS" << EOF
# Solarized Dark Color Scheme for Kitty

background #002b36
foreground #839496
cursor #93a1a1
selection_background #073642
selection_foreground #93a1a1

color0  #073642
color1  #dc322f
color2  #859900
color3  #b58900
color4  #268bd2
color5  #d33682
color6  #2aa198
color7  #eee8d5
color8  #657b83
color9  #cb4b16
color10 #586e75
color11 #657b83
color12 #839496
color13 #6c71c4
color14 #93a1a1
color15 #fdf6e3
EOF

echo "Kitty instalado y configurado."




# Limpiar los archivos temporales
sudo rm -f "$checked_user"
sudo rm -f "$0"
exit 0
