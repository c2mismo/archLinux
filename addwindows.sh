#!/bin/bash

# Añadimos al menu de arranque del grub windows

# Partición de windows
WIN_PART="/dev/nvme0n1p1"

# Ruta del archivo a modificar
GRUB_FILE="/etc/grub.d/40_custom"


# Contador de intentos
attempts=0
max_attempts=3
uuid=""

# Verificar el UUID hasta 3 veces
while [ $attempts -lt $max_attempts ]; do
    uuid=$(blkid -s UUID -o value $WIN_PART)
    
    if [ -n "$uuid" ]; then
        echo "UUID encontrado: $uuid"
        echo "Numero de intentos: $((attempts + 1))"  
        break
    else
        echo "Intento $((attempts + 1)): No se encontró UUID. Reintentando..."
        attempts=$((attempts + 1))
        sleep 1  # Esperar 1 segundo antes de volver a intentar
    fi
done

# Si se encontró un UUID
# Le añadimos las lineas necesarias para que el grub
# pueda configurar correctamente el arranque de windows
if [ -n "$uuid" ]; then
  echo "" | tee -a $GRUB_FILE > /dev/null
  echo "menuentry \"Windows 11\" {" | tee -a $GRUB_FILE > /dev/null
  echo "    insmod part_gpt" | tee -a $GRUB_FILE > /dev/null
  echo "    insmod search_fs_uuid" | tee -a $GRUB_FILE > /dev/null
  echo "    insmod chain" | tee -a $GRUB_FILE > /dev/null
  echo "    search --fs-uuid --set=root $uuid" | tee -a $GRUB_FILE > /dev/null
  echo "    chainloader /EFI/Microsoft/Boot/bootmgfw.efi" | tee -a $GRUB_FILE > /dev/null
  echo "}" | tee -a $GRUB_FILE > /dev/null
else
    echo "No se pudo encontrar un UUID después de $max_attempts intentos."
fi

