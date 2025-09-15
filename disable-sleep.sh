#!/bin/bash
[[ $EUID -ne 0 ]] && echo "Ejecuta como root" && exit 1

# Paso 1: Mascara systemd
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Paso 2: Configura sleep.conf.d
mkdir -p /etc/systemd/sleep.conf.d
echo "[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowHybridSleep=no
AllowSuspendThenHibernate=no" > /etc/systemd/sleep.conf.d/99-nopower.conf

# Paso 3: Configura logind.conf
sed -i 's/^#\(HandlePowerKey\|HandleHibernateKey\|HandleSuspendKey\|HandleLidSwitch\|HandleLidSwitchExternalPower\).*/\1=ignore/' /etc/systemd/logind.conf
sed -i 's/^HandlePowerKeyLongPress.*/HandlePowerKeyLongPress=poweroff/' /etc/systemd/logind.conf
sed -i 's/^HandleHibernateKeyLongPress.*/HandleHibernateKeyLongPress=ignore/' /etc/systemd/logind.conf
sed -i 's/^HandleSuspendKeyLongPress.*/HandleSuspendKeyLongPress=ignore/' /etc/systemd/logind.conf
systemctl restart systemd-logind

# Paso 4: Configura PowerDevil
mkdir -p ~/.config/systemd/user/plasma-powerdevil.service.d
cat > ~/.config/systemd/user/plasma-powerdevil.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/lib/org_kde_powerdevil --no-suspend --no-hibernate
EOF
systemctl --user daemon-reload
systemctl --user restart plasma-powerdevil.service

echo -e "\n✅ Configuración completada. Verifica con:"
echo "systemctl status sleep.target suspend.target"
echo "systemctl --user status plasma-powerdevil.service"

# Limpiar los archivos temporales
sudo rm -f "$0"
exit 0
