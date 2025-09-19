#!/bin/bash

# Modificamos las opciones de montaje del inicio del sistema en /etc/fstab,
# para la partición WINLINUX como exFAT.
# Los sistemas de archivos como FAT o exFAT no tienen el concepto de permisos nativo
# de usuario de Unix/Linux.

# Las opciones umask, fmask y dmask en el montaje de sistemas de archivos como FAT o exFAT
# controlan cómo se "muestran" los permisos de los archivos y directorios
# desde el punto de vista de Linux, solo controlan cómo se muestran los permisos,
# no cómo se almacenan.

# Por lo que no puedes cambiar el propietario (chown) ni los permisos (chmod) de los
# archivos y directorios en una partición exFAT de la misma manera que
# lo harías en ext4 o btrfs.

# Para que todos los usuarios tengan todos los permisos, (uso nativo exFAT), usamos
# umask=000, que define una máscara de permisos que se aplica a todos
# los archivos y directorios en el sistema de archivos montado.
# Esto significa que "no" oculta los bits de permiso para "grupo" y "otros".

# --- Configuración ---
# Define el punto de montaje DENTRO del chroot
WINLINUX_MOUNT_POINT="/mnt/WINLINUX"
# --- Fin Configuración ---


# Creamos el fstab para el montaje automático al inicio del sistema
# desde el sistema despues de haber creado el user

genfstab -U -p / >> /etc/fstab

# Este script se ejecuta DENTRO del chroot, por lo tanto:
# - Las rutas son relativas a la nueva raíz (/) del sistema instalado.
# - El fstab objetivo es /etc/fstab


echo "Modificando fstab DENTRO del chroot para $WINLINUX_MOUNT_POINT..."

# Verificar si fstab existe
if [[ ! -f /etc/fstab ]]; then
    echo "Error: /etc/fstab no encontrado dentro del chroot."
    exit 1
fi

# Verificar si la línea para WINLINUX_MOUNT_POINT existe en fstab
if ! grep -q "$WINLINUX_MOUNT_POINT" /etc/fstab; then
    echo "Advertencia: No se encontró una entrada para $WINLINUX_MOUNT_POINT en /etc/fstab."
    echo "Asegúrate de que la partición esté montada y 'genfstab' se haya ejecutado correctamente antes."
    # Opcionalmente, podrías salir o intentar añadir la línea manualmente aquí.
    # exit 1
    # Por ahora, solo advertimos.
fi

# --- Modificamos la línea de WINLINUX ---
# Usamos sed para buscar cualquier línea que contenga SOLAMENTE el punto de montaje
# y reemplazar toda la línea con nuestra configuración deseada.

# Esta expresión busca líneas que contienen el punto de montaje específico
# y la marca temporalmente para identificarla fácilmente.
# [^[:space:]]* asegura que coincidimos con el campo completo del punto de montaje
sed -i "s|.*$WINLINUX_MOUNT_POINT[^[:space:]]*.*|&\n# LINEA_MODIFICADA_POR_SCRIPT|" /etc/fstab

if grep -q "# LINEA_MODIFICADA_POR_SCRIPT" /etc/fstab; then
     # Extraer el UUID o dispositivo de la línea original (asumiendo formato estándar)
     # Buscamos la línea antes del marcador temporal
     ORIGINAL_LINE=$(grep -B 1 "# LINEA_MODIFICADA_POR_SCRIPT" /etc/fstab | head -n 1)
     # Intentar extraer UUID primero
     UUID=$(echo "$ORIGINAL_LINE" | grep -o 'UUID=[^[:space:]]*' | head -n1)

     if [[ -n "$UUID" ]]; then
         # Si se encontró UUID, usarlo
         NEW_ENTRY="$UUID $WINLINUX_MOUNT_POINT exfat rw,relatime,umask=000,iocharset=utf8,errors=remount-ro 0 2"
     else
         # Si no hay UUID, intentar usar el dispositivo (primera columna)
         DEVICE=$(echo "$ORIGINAL_LINE" | awk '{print $1}')
         if [[ -n "$DEVICE" && "$DEVICE" != "#" ]]; then
             NEW_ENTRY="$DEVICE $WINLINUX_MOUNT_POINT exfat rw,relatime,umask=000,iocharset=utf8,errors=remount-ro 0 2"
         else
             echo "Error: No se pudo determinar el dispositivo o UUID de la línea original."
             sed -i "/# LINEA_MODIFICADA_POR_SCRIPT/d" /etc/fstab # Limpiar marca
             exit 1
         fi
     fi

     # Reemplazar la línea original y el marcador con la nueva entrada
     # Usamos un delimitador poco común (#) para evitar conflictos con /
     # Asegurarse de escapar el $ en la variable NEW_ENTRY si se usa #
     # Mejor usar otro delimitador o construir el comando con comillas dobles
     # Construimos el patrón de búsqueda y reemplazo cuidadosamente
     # Escapamos / en NEW_ENTRY si es necesario (aunque es poco probable aquí)
     ESCAPED_NEW_ENTRY=$(printf '%s\n' "$NEW_ENTRY" | sed 's/[&/\]/\\&/g') # Escapar caracteres especiales para sed
     sed -i "N; s|.*$WINLINUX_MOUNT_POINT[^[:space:]]*.*\n# LINEA_MODIFICADA_POR_SCRIPT|$ESCAPED_NEW_ENTRY|" /etc/fstab

     echo "Entrada de fstab para $WINLINUX_MOUNT_POINT modificada exitosamente."
     echo "Nueva entrada: $NEW_ENTRY"

else
    echo "Error: No se pudo identificar la línea a modificar en fstab para $WINLINUX_MOUNT_POINT."
    exit 1
fi

# Verificamos el cambio final (opcional)
echo "--- Contenido relevante del fstab después de la modificación ---"
grep "$WINLINUX_MOUNT_POINT" /etc/fstab
echo "--- Fin del contenido ---"

echo "Modificación de fstab completado."

cat /etc/fstab

# Limpiar los archivos temporales
sudo rm -f "$0"
exit 0
