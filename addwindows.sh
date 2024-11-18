#!/bin/bash

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Añadimos al menú de arranque del grub Windows

# Partición de Windows
EFI_PART="/dev/nvme0n1p1"

# Ruta del archivo a modificar
GRUB_FILE="/etc/grub.d/40_custom"

# Contador de intentos
attempts=0
max_attempts=3
uuid=""

# Verificar el UUID hasta 3 veces
while [ $attempts -lt $max_attempts ]; do
    uuid=$(blkid -s UUID -o value $EFI_PART)
    
    if [ -n "$uuid" ]; then
        echo "UUID encontrado: $uuid"
        echo "Número de intentos: $((attempts + 1))"
        break
    else
        echo "Intento $((attempts + 1)): No se encontró UUID. Reintentando..."
        attempts=$((attempts + 1))
        sleep 1  # Esperar 1 segundo antes de volver a intentar
    fi
done

# Si se encontró un UUID
# Le añadimos las líneas necesarias para que el grub
# pueda configurar correctamente el arranque de Windows
if [ -n "$uuid" ]; then
    cp "$GRUB_FILE" "$GRUB_FILE.backup" || { echo "Error al crear la copia de seguridad de $GRUB_FILE"; exit 1; }
    
    # Añadir la entrada de Windows al archivo de configuración de GRUB
    cat >> "$GRUB_FILE" << EOF

menuentry "Windows 11" {
    insmod part_gpt
    insmod search_fs_uuid
    insmod chain
    search --fs-uuid --set=root $uuid
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
}
EOF

    echo "Entrada de Windows 11 añadida a $GRUB_FILE."
else
    echo "No se pudo encontrar un UUID después de $max_attempts intentos."
fi
