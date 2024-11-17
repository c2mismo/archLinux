#!/bin/bash
# Generamos configuraciones para reconocimiento local para representar texto,
# mostrar correctamente valores monetarios regionales, formatos de fecha y hora,
# idiosincrasias alfabéticas y otros estándares específicos de la región.
# Si lo hacemos asi todos los usuarios nuevos creados con useradd -m "usuario"
# se les creará automáticamente un ~/.config/locale.conf con la configuración
# que hayamos definido en el archivo siguiente, lo prefiero de esta forma
# el sistema base, el superadmin y los logs seguirán en inglés.

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc

# Configuración del sistema (Inglés con teclado español)
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#es_ES.UTF-8/es_ES.UTF-8/' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=es" > /etc/vconsole.conf
echo "FONT=ter-v32n" >> /etc/vconsole.conf

# Configuración para nuevos usuarios (Español)
mkdir -p /etc/skel/.config

echo "LANG=es_ES.UTF-8" > /etc/skel/.config/locale.conf

# Instalar terminus-font
pacman -Syu --noconfirm
pacman -S --noconfirm terminus-font

# Configurar vconsole.conf para nuevos usuarios
echo "KEYMAP=es" > /etc/skel/.config/vconsole.conf
echo "FONT=ter-v32n" >> /etc/skel/.config/vconsole.conf
echo "FONT_MAP=UTF-8" >> /etc/skel/.config/vconsole.conf

# Configuración de X11 para el teclado español
mkdir -p /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/00-keyboard.conf << EOF
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "es"
EndSection
EOF

# Asegurar que los nuevos usuarios carguen su configuración
echo "[ -f ~/.config/locale.conf ] && . ~/.config/locale.conf" >> /etc/skel/.bash_profile
echo "[ -f ~/.config/vconsole.conf ] && . ~/.config/vconsole.conf" >> /etc/skel/.bash_profile

echo "Idioma para los usuarios configurada en español completado."
