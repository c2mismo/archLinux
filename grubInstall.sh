#!/bin/bash

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Definir variables
EFI_DIRECTORY="/boot/efi"
BOOTLOADER_ID="GRUB"

# Instalar GRUB
echo "Instalando GRUB..."
grub-install --target=x86_64-efi --efi-directory="$EFI_DIRECTORY" --bootloader-id="$BOOTLOADER_ID"

# Verificar si la instalación fue exitosa
if [ $? -ne 0 ]; then
  echo "Error: La instalación de GRUB falló."
  exit 1
fi

# Generar la configuración de GRUB
echo "Generando la configuración de GRUB..."
grub-mkconfig -o /boot/grub/grub.cfg

# Verificar si la generación fue exitosa
if [ $? -ne 0 ]; then
  echo "Error: La generación de la configuración de GRUB falló."
  exit 1
fi

echo "GRUB ha sido instalado y la configuración ha sido generada correctamente."

# Limpiar los archivos temporales
sudo rm -f "$0"
