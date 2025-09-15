#!/bin/bash
[[ $EUID -ne 0 ]] && echo "Ejecuta como root" && exit 1

# Paso 1: Mascara systemd
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Paso 2: Configura sleep.conf.d
# Verificar si existe || no ejecutar
# && Crear:
mkdir -p /etc/systemd/sleep.conf.d
echo "[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowHybridSleep=no
AllowSuspendThenHibernate=no" > /etc/systemd/sleep.conf.d/99-nopower.conf

# Paso 3: Configura logind.conf
# Verificar si existe || no ejecutar
# && Crear:
sed -i 's/^#\(HandlePowerKey\|HandleHibernateKey\|HandleSuspendKey\|HandleLidSwitch\|HandleLidSwitchExternalPower\).*/\1=ignore/' /etc/systemd/logind.conf
sed -i 's/^HandlePowerKeyLongPress.*/HandlePowerKeyLongPress=poweroff/' /etc/systemd/logind.conf
sed -i 's/^HandleHibernateKeyLongPress.*/HandleHibernateKeyLongPress=ignore/' /etc/systemd/logind.conf
sed -i 's/^HandleSuspendKeyLongPress.*/HandleSuspendKeyLongPress=ignore/' /etc/systemd/logind.conf
# este paso que se ejecute al reiniciar
systemctl restart systemd-logind

# Paso 4: Configura PowerDevil
# verificar si está plasma instalado
# verificar si hay usuarios
# y por usuario:
# Verificar si existe /home/$USER1/.config/systemd/user/plasma-powerdevil.service.d/override.conf
# || no ejecutar
# && Crear:

# Ejecuta esto como root para aplicar a TODOS los usuarios con home en /home/
for user_dir in /home/*; do
    user=$(basename "$user_dir")
    mkdir -p "$user_dir/.config/systemd/user/plasma-powerdevil.service.d"
    cat > "$user_dir/.config/systemd/user/plasma-powerdevil.service.d/override.conf" <<EOF
[Service]
ExecStart=
ExecStart=/usr/lib/org_kde_powerdevil --no-suspend --no-hibernate
EOF
    chown -R "$user:$user" "$user_dir/.config/systemd/user/plasma-powerdevil.service.d"
done

systemctl --user daemon-reload
systemctl --user restart plasma-powerdevil.service

echo -e "\n✅ Configuración completada. Verifica con:"
echo "systemctl status sleep.target suspend.target"
echo "systemctl --user status plasma-powerdevil.service"

# Limpiar los archivos temporales
sudo rm -f "$0"
exit 0
