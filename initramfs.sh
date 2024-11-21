#!/bin/bash

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Ruta al archivo de configuración
MKINITCPIO_CONF="/etc/mkinitcpio.conf.backup"

cp MKINITCPIO_CONF MKINITCPIO_CONF.backup

# Modificar la línea de MODULES para porcesadores Intel
sed -i 's/^MODULES=().*/MODULES=(i915)/' "$MKINITCPIO_CONF"

# Incluimos los modules del kernel necesarios para que initramfs pueda desencriptar
# usando systemd, recuerda sd-encrypt debe estar antes que filesystems
# Comentamos la linea para udev porque vamos a usar systemd
# Incluimos los modules del kernel necesarios para que initramfs pueda desencriptar
# usando systemd, recuerda sd-encrypt debe estar antes que filesystems y
# Primero verificamos si existe el archivo /etc/vconsole.conf y si contiene 'FONT='
# para añadir el HOOK consolefont al usar systemd sería sd-vconsole

if [ -f "$VCONSOLE_CONF" ]; then

  if grep -q '^FONT=' "$VCONSOLE_CONF"; then

    # Modificar la línea de HOOKS si FONT= está presente

    sed -i 's/^HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)/#    HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)/' "$MKINITCPIO_CONF"

    sed -i 's/^#    HOOKS=(base systemd autodetect modconf kms keyboard sd-vconsole sd-encrypt block filesystems fsck)/HOOKS=(base systemd autodetect microcode modconf kms keyboard keymap sd-vconsole sd-encrypt block filesystems fsck)/' "$MKINITCPIO_CONF"

    echo "La línea de HOOKS ha sido modificada en $MKINITCPIO_CONF." && flag=1;

  else

    echo "Advertencia: El archivo $VCONSOLE_CONF no contiene 'FONT='. Por favor, modifícalo antes de continuar."

  fi

else

  echo "Advertencia: El archivo $VCONSOLE_CONF no existe. Por favor, crea este archivo antes de continuar."

fi


if [ $flag = "1" ]; then
  # Confirmar que se han realizado los cambios
  echo "Modificaciones realizadas en $MKINITCPIO_CONF:"
  grep '^MODULES=' "$MKINITCPIO_CONF"
  grep '^HOOKS=' "$MKINITCPIO_CONF"
  
  # Regenerar la imagen del initramfs
  mkinitcpio -P
  
  echo "La imagen del initramfs ha sido regenerada."
fi

