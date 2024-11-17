#!/bin/bash

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Configuramos el sistema para que haga el menor uso de swap posible
[ ! -e /etc/sysctl.d/99-sysctl.conf ] && touch /etc/sysctl.d/99-sysctl.conf
echo "vm.swappiness=10" | tee -a /etc/sysctl.d/99-sysctl.conf > /dev/null

# Partición swap
SWAP_PART="/dev/nvme0n1p8"
# LABEL de la swap
SWAP_LABEL="swap"
# NAME desencriptada
SWAP_CRYPT="volatileswap"
# Ruta del archivo a modificar
CRYPTTAB_FILE="/etc/crypttab.initramfs"

# Creamos un sistema de archivos pequeño (por ejemplo, de 1 MiB) en la partición de swap y
# especificamos un offset que determina dónde comienza este sistema de archivos.
# Al establecer un offset, el sistema de archivos pequeño se coloca en la parte superior de la partición,
# dejando el resto de la partición (donde se encuentra el swap encriptado) intacto.
# Esto significa que el UUID y el LABEL de la partición de swap no se sobrescriben,
# ya que no se modifican los primeros sectores de la partición donde se almacenan estos identificadores.

mkfs.ext4 -L $SWAP_LABEL -m 0 -O ^has_journal $SWAP_PART -s 1M

# -m 0: No reserva espacio para el superusuario, maximizando el espacio disponible para swap.
# -O ^has_journal: Desactiva el journaling, lo que es innecesario para una partición de swap y mejora el rendimiento.
# -s 1M limita el tamaño del sistema de archivos a 1 MiB, dejando espacio para el swap encriptado detrás de él.


# Verificamos que existe crypttab.initramfs y si no lo creamos y le añadimos las lineas necesarias
# para que reencripte la partición a cada inicio
[ ! -e $CRYPTTAB_FILE ] && cp /etc/crypttab $CRYPTTAB_FILE
echo "" | tee -a $CRYPTTAB_FILE > /dev/null
echo "# Mount swap re-encrypting it with a fresh key each reboot" | tee -a $CRYPTTAB_FILE > /dev/null
# especificamos un offset=2048 para que que el UUID y el LABEL de la partición de swap no se sobrescriban.
echo "$SWAP_CRYPT    LABEL=$SWAP_LABEL    /dev/urandom    swap,offset=2048,cipher=aes-xts-plain64,size=256,sector-size=4096" | tee -a $CRYPTTAB_FILE > /dev/null



# Configuramos el fstab para que se monte correctamente
echo "# /dev/mapper/$SWAP_CRYPT LABEL=$SWAP_LABEL" | tee -a /etc/fstab > /dev/null
echo "/dev/mapper/$SWAP_CRYPT    none    swap    sw    0 0" | tee -a /etc/fstab > /dev/null
