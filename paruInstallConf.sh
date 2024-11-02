#!/bin/bash

echo "Instalando y configurando paru..."

# Instalar dependencias necesarias
sudo pacman -S --needed base-devel git

# Clonar el repositorio de paru
git clone https://aur.archlinux.org/paru.git
cd paru

# Compilar e instalar paru
makepkg -si --noconfirm

# Volver al directorio anterior y limpiar
cd ..
rm -rf paru

echo "Paru ha sido instalado."

# Crear el directorio de configuración de paru si no existe
mkdir -p ~/.config/paru

# Crear el archivo de configuración de paru
cat << EOF > ~/.config/paru/paru.conf
[options]
BottomUp
SudoLoop
CleanAfter
UpgradeMenu
NewsOnUpgrade
RemoveMake
BatchInstall
UseAsk
CombinedUpgrade
#SkipReview

[bin]
FileManager = ranger
EOF

echo "Configuración completada. Paru está listo para usar."
echo "Recuerda ejecutar 'paru -Syu' para actualizar tu sistema y los paquetes AUR."
