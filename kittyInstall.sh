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
# Incluye el archivo colors.conf en kitty.conf y configura las fuentes:

include colors.conf  # Incluye los colores del archivo colors.conf
font_family monospace  # Establece la familia de fuentes
bold_font auto  # Selección automática de fuente en negrita
italic_font auto  # Selección automática de fuente en cursiva
bold_italic_font auto  # Selección automática de fuente en negrita cursiva
font_size 14.0  # Tamaño de la fuente
font_spacing 0.5  # Espaciado entre letras
line_height 1.2  # Espaciado entre líneas
antialiasing true  # Suavizado de texto

scrollback_lines 50  # Número de líneas en el historial

# shell zsh  # Tipo de shell por defecto bash, zsh, etc

# Configuración para ocultar el cursor tras un tiempo de inactividad:

mouse_hide_wait 3.0  # Oculta el cursor tras 3 segundos de inactividad:

# Configuración para la detección automática de URLs:

detect_urls yes  # Habilita la detección automática de URLs
url_color #0087bd  # Color de las URLs
url_style double  # Estilo de subrayado de las URLs
open_url_with default  # Navegador predeterminado para abrir URLs
url_prefixes ftp ssh http https git irc sftp  # Prefijos de URLs a detectar
show_hyperlink_targets yes  # Muestra los objetivos de los hipervínculos

# Configura el manejo de ventanas similar a Tmux:

draw_minimal_borders yes  # Bordes mínimos
placement_strategy center  # Estrategia de colocación de ventanas
active_border_color #808000  # Color del borde de la ventana activa
inactive_text_alpha 0.5  # Transparencia del texto en ventanas inactivas

# Configuración avanzada de pestañas similar a tmux:

tab_bar_edge bottom  # Pestañas en la parte inferior
tab_bar_margin_with 0.1  # Margen entre pestañas
tab_bar_style powerline  # Estilo de las pestañas
tab_bar_min_tabs 1  # Mínimo de pestañas
inactive_tab_background #e06c75  # Fondo de pestañas inactivas
inactive_tab_foreground #000000  # Color de texto de pestañas inactivas
active_tab_background #98c379  # Fondo de pestañas activas
bell_border_color #ff5a00  # Color de borde de notificación
tab_separator " |"  # Separador entre pestañas
tab_activity_symbol none  # Sin símbolo de actividad
tab_bar_margin_color #FFFF00  # Color del margen de la barra de pestañas
background_blur 0.6  # Desenfoque del fondo

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
KITTY_COLORS="$HOME/.config/kitty/colors.conf"

cat > "$KITTY_COLORS" << EOF
background #1d1f21
foreground #c4c8c5
cursor #c4c8c5
selection_background #363a41
color0 #000000
color8 #000000
color1 #cc6666
color9 #cc6666
color2 #b5bd68
color10 #b5bd68
color3 #f0c574
color11 #f0c574
color4 #80a1bd
color12 #80a1bd
color5 #b294ba
color13 #b294ba
color6 #8abdb6
color14 #8abdb6
color7 #fffefe
color15 #fffefe
selection_foreground #1d1f2
EOF

echo "Kitty instalado y configurado."




# Limpiar los archivos temporales
sudo rm -f "$checked_user"
sudo rm -f "$0"
