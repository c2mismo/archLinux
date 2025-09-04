#!/bin/bash

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi


# === MEJORA AQUÍ: Configurar parámetro de sonido en GRUB ===
echo "Configurando parámetros de kernel para HDA Intel PCH..."
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet snd_hda_intel.dmic_detect=0"/' /etc/default/grub

# Verificar si la modificación fue exitosa
if [ $? -ne 0 ]; then
  echo "Error: No se pudo actualizar /etc/default/grub."
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

echo "GRUB ha sido instalado y configurado correctamente con soporte para HDA Intel PCH."

# Limpiar el script temporal
rm -f "$0"
