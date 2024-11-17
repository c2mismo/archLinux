#!/bin/bash
# Desabilitamos la hibernación,
# obligatorio si queremos tener una
# swap volatil

# Asegúrate de que el script se ejecute como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

cat > /etc/systemd/sleep.conf.d << EOF
[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowHybridSleep=no
AllowSuspendThenHibernate=no
EOF && echo "Desabilitada la hibernación"

rm disable-sleep.sh
