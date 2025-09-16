#!/bin/bash

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Ruta de los archivos en el sistema
UDISKS2_FILE="/etc/udisks2/mount_options.conf"

# Añadir al crypttab (USANDO UUID Y /dev/urandom)
echo "Añadiendo a $UDISKS2_FILE..."
cat >> "$UDISKS2_FILE" << EOF
[defaults]
allow=exec,noexec,nodev,nosuid,atime,noatime,nodiratime,relatime,strictatime,lazytime,ro,rw,sync,dirsync,noload,acl,nosymfollow

# Opciones para ntfs-3g (driver fuse)
ntfs:ntfs_defaults=uid=$UID,gid=$GID,windows_names,force
ntfs:ntfs_allow=uid=$UID,gid=$GID,umask,dmask,fmask,locale,norecover,ignore_case,windows_names,compression,nocompression,big_writes,force

# Opciones para el nuevo driver ntfs3 del kernel (si está disponible)
ntfs:ntfs3_defaults=uid=$UID,gid=$GID,force
ntfs:ntfs3_allow=uid=$UID,gid=$GID,umask,dmask,fmask,iocharset,discard,nodiscard,sparse,nosparse,hidden,nohidden,sys_immutable,nosys_immutable,showmeta,noshowmeta,prealloc,noprealloc,hide_dot_files,nohide_dot_files,windows_names,nocase,case,force

# Definir el orden de prioridad de los drivers
ntfs_drivers=ntfs,ntfs3
EOF

systemctl restart udisks2.service

echo -e "\n✅ Configuración para montaje de discos ntfs completado."

# Limpiar los archivos temporales
sudo rm -f "$0"
exit 0
