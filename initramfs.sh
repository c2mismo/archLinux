#!/bin/bash

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Ruta al archivo de configuración
MKINITCPIO_CONF="/etc/mkinitcpio.conf.backup"
VCONSOLE_CONF="/etc/vconsole.conf"
BACKUP_CONF="/etc/mkinitcpio.conf.backup.backup"

# Hacer una copia de seguridad del archivo de configuración
cp "$MKINITCPIO_CONF" "$BACKUP_CONF"

# Modificar la línea de MODULES para procesadores Intel
sed -i 's/^MODULES=().*/MODULES=(i915)/' "$MKINITCPIO_CONF"

# Inicializar la variable flag
flag=0

# Verificar si existe el archivo /etc/vconsole.conf y si contiene 'FONT='
if [ -f "$VCONSOLE_CONF" ]; then
  if grep -q '^FONT=' "$VCONSOLE_CONF"; then
    # Modificar la línea de HOOKS si FONT= está presente
    sed -i 's/^HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)/#    HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)/' "$MKINITCPIO_CONF"
    sed -i 's/^#    HOOKS=(base systemd autodetect modconf kms keyboard keymap block filesystems fsck)/HOOKS=(base systemd autodetect microcode modconf kms keyboard keymap sd-vconsole sd-encrypt block filesystems fsck)/' "$MKINITCPIO_CONF"
    echo "La línea de HOOKS ha sido modificada en $MKINITCPIO_CONF."
    flag=1
  else
    echo "Advertencia: El archivo $VCONSOLE_CONF no contiene 'FONT='. Por favor, modifícalo antes de continuar."
  fi
else
  echo "Advertencia: El archivo $VCONSOLE_CONF no existe. Por favor, crea este archivo antes de continuar."
fi

# Confirmar que se han realizado los cambios
if [ $flag -eq 1 ]; then
  echo "Modificaciones realizadas en $MKINITCPIO_CONF:"
  grep '^MODULES=' "$MKINITCPIO_CONF"
  grep '^HOOKS=' "$MKINITCPIO_CONF"
  
  # Regenerar la imagen del initramfs
  # mkinitcpio -P
  
  echo "La imagen del initramfs ha sido regenerada."
fi
