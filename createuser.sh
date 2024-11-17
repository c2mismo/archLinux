#!/bin/bash

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Cambiar la contraseña de root
echo "Cambiando la contraseña de root..."
passwd

# Crear nuevo usuario "visitante"
echo "Creando el nuevo usuario 'visitante'..."
useradd -m visitante
echo "Estableciendo la contraseña para 'visitante'..."
passwd visitante
usermod -aG video,audio,storage visitante
echo "Usuario 'visitante' creado y configurado."

# Crear nuevo usuario con permisos de superusuario
read -p "Introduce el nombre del nuevo usuario con permisos de superusuario: " usuario
echo "Creando el nuevo usuario '$usuario'..."
useradd -m "$usuario"
echo "Estableciendo la contraseña para '$usuario'..."
passwd "$usuario"
usermod -aG wheel,video,audio,storage "$usuario"
echo "Usuario '$usuario' creado y configurado con permisos de superusuario."

# Modificar el archivo sudoers
echo "Modificando el archivo /etc/sudoers..."
if ! grep -q "%wheel ALL=(ALL) ALL" /etc/sudoers; then
  echo "Descomentando la línea %wheel en /etc/sudoers..."
  sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
else
  echo "La línea %wheel ya está descomentada."
fi

# Cambiar el nombre de la máquina
read -p "Introduce el nombre de esta máquina: " nombre_maquina
echo "Estableciendo el nombre de la máquina a '$nombre_maquina'..."
echo "$nombre_maquina" > /etc/hostname
echo "Nombre de la máquina configurado."

rm createuser.sh
