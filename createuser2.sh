#!/bin/bash

echo "Modificando el archivo /etc/sudoers..."

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Comprobar si la línea está comentada
if grep -q "^# %wheel ALL=(ALL) ALL" /etc/sudoers; then
  echo "La línea está comentada. Descomentando..."
  sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
  echo "Línea descomentada."
else
  # Comprobar si la línea ya está descomentada
  if grep -q "%wheel ALL=(ALL) ALL" /etc/sudoers; then
    echo "La línea %wheel ya está descomentada."
  else
    # Si la línea no existe, añadirla después de la línea de root
    echo "La línea %wheel no existe. Añadiéndola después de la línea 'root ALL=(ALL:ALL) ALL'..."
    sed -i "/^root ALL=(ALL:ALL) ALL/a %wheel ALL=(ALL) ALL" /etc/sudoers
    echo "Línea añadida."
  fi
fi

rm createuser2.sh
