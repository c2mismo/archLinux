#!/bin/bash

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Partición de root
ROOT_PART="/dev/nvme0n1p5"

# Ruta del archivo a modificar
CRYPTTAB_FILE="/etc/crypttab.initramfs"

# Contador de intentos
attempts=0
max_attempts=3
uuid=""

# Verificar el UUID hasta 3 veces
while [ $attempts -lt $max_attempts ]; do
    uuid=$(blkid -s UUID -o value $ROOT_PART)
    
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
# Verificamos que existe crypttab.initramfs y si no lo creamos y le añadimos las lineas necesarias
# para que encripte la partición al cada inicio
if [ -n "$uuid" ]; then
    [ ! -e $CRYPTTAB_FILE ] && cp /etc/crypttab $CRYPTTAB_FILE
    echo "" | tee -a $CRYPTTAB_FILEE > /dev/null
    echo "# Mount root as /dev/mapper/cryptroot using LUKS, and prompt for the passphrase at boot time." | tee -a $CRYPTTAB_FILEE > /dev/null
    echo "cryptroot    UUID=$uuid    none    luks,discard,no-read-workqueue,no-write-workqueue,password-echo=no" | tee -a $CRYPTTAB_FILE > /dev/null
else
    echo "No se pudo encontrar un UUID después de $max_attempts intentos."
fi
