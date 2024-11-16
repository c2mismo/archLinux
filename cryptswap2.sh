#!/bin/bash

# Ruta del archivo a modificar
CRYPTTAB_FILE="/etc/crypttab.initramfs"

# Contador de intentos
attempts=0
max_attempts=3
uuid=""

# Verificar el UUID hasta 3 veces
while [ $attempts -lt $max_attempts ]; do
    uuid=$(blkid -s UUID -o value /dev/nvme0n1p8)
    
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

# Si se encontró un UUID, modificar el archivo
if [ -n "$uuid" ]; then
    echo "Modificando el archivo $CRYPTTAB_FILE..."
    sed -i "s/YYY/$uuid/g" "$CRYPTTAB_FILE"
    echo "Se ha reemplazado 'YYY' por '$uuid' en $CRYPTTAB_FILE."
else
    echo "No se pudo encontrar un UUID después de $max_attempts intentos."
fi
