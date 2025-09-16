#!/bin/bash

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Cambiar la contraseña de root
echo "Cambiando la contraseña de root..."
passwd

# Crear nuevo usuario "visitante" sin permisos de superuser
# Verificar si el usuario "visitante" ya existe
if id "visitante" &>/dev/null; then
  echo "El usuario 'visitante' ya existe. No se creará de nuevo."
else
  # Crear nuevo usuario "visitante"
  echo "Creando el nuevo usuario 'visitante'..."
  useradd -m visitante
  echo "Estableciendo la contraseña para 'visitante'..."
  passwd visitante
  usermod -aG video,audio,storage visitante
  echo "Usuario 'visitante' creado y configurado."
fi

# Crear nuevo usuario con permisos de superusuario
read -p "Introduce el nombre del nuevo usuario con permisos de superusuario: " usuario

# Verificar si se ha introducido un nombre de usuario
if [ -z "$usuario" ]; then
  echo "No se crea usuario: No se ha introducido nombre de usuario."
else
  echo "Creando el nuevo usuario '$usuario'..."
  useradd -m "$usuario"
  echo "Estableciendo la contraseña para '$usuario'..."
  passwd "$usuario"
  usermod -aG wheel,video,audio,storage,disk,uucp "$usuario"
  echo "Usuario '$usuario' creado y configurado con permisos de superusuario."
fi


# Modificar el archivo sudoers
# Comprobar si la línea está comentada
if grep -q "^# %wheel ALL=(ALL:ALL) ALL" /etc/sudoers; then
  echo "La línea está comentada. Descomentando..."
  sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
  echo "Línea descomentada."
else
  # Comprobar si la línea ya está descomentada
  if grep -q "%wheel ALL=(ALL:ALL) ALL" /etc/sudoers; then
    echo "La línea %wheel ya está descomentada."
  else
    # Si la línea no existe, añadirla después de la línea de root
    echo "La línea %wheel no existe. Añadiéndola después de la línea 'root ALL=(ALL:ALL) ALL'..."
    sed -i "/^root ALL=(ALL:ALL) ALL/a %wheel ALL=(ALL:ALL) ALL" /etc/sudoers
    echo "Línea añadida."
  fi
fi

# Cambiar el nombre de la máquina

read -p "Introduce el nombre de esta máquina: " nombre_maquina
if [ -z "nombre_maquina" ]; then
  echo "No se modifica el nombre de la máquina: No se ha introducido nombre nuevo de máquina."
else
  echo "Estableciendo el nombre de la máquina a '$nombre_maquina'..."
  echo "$nombre_maquina" > /etc/hostname
  echo "Nombre de la máquina configurado."
fi

# Verificar si los man-pages están instalados
if ! pacman -Qi reflector > /dev/null 2>&1; then
    sudo pacman -S --noconfirm man-pages man-db
fi


# Limpiar los archivos temporales
sudo rm -f "$0"
exit 0
