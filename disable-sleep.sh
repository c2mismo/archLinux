#!/bin/bash

# Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Este script debe ejecutarse como root. Usa 'sudo $0'"
    exit 1
fi

# Verificar si KDE Plasma está instalado
if [ ! -f /usr/lib/org_kde_powerdevil ]; then
    echo "Error: KDE Plasma no está instalado. Instálalo primero con:"
    echo "sudo pacman -S plasma-desktop"
    exit 1
fi

# 1. Mascara los objetivos de systemd
echo "Mascarando objetivos de suspensión/hibernación..."
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# 2. Configurar sleep.conf.d
echo "Configurando /etc/systemd/sleep.conf.d/99-nopower.conf..."
mkdir -p /etc/systemd/sleep.conf.d
cat > /etc/systemd/sleep.conf.d/99-nopower.conf <<EOF
[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowHybridSleep=no
AllowSuspendThenHibernate=no
EOF

# 3. Configurar logind.conf
echo "Configurando /etc/systemd/logind.conf..."
settings=(
    "HandlePowerKey=ignore"
    "HandlePowerKeyLongPress=poweroff"
    "HandleHibernateKey=ignore"
    "HandleHibernateKeyLongPress=ignore"
    "HandleSuspendKey=ignore"
    "HandleSuspendKeyLongPress=ignore"
    "HandleLidSwitch=ignore"
    "HandleLidSwitchExternalPower=ignore"
)

for setting in "${settings[@]}"; do
    key="${setting%=*}"
    value="${setting#*=}"
    if grep -q "^$key=" /etc/systemd/logind.conf; then
        sed -i "s/^$key=.*/$key=$value/" /etc/systemd/logind.conf
    else
        echo "$key=$value" >> /etc/systemd/logind.conf
    fi
done
# systemctl restart systemd-logind

# 4. Configurar PowerDevil para usuarios existentes
echo -e "\n\033[1;34mConfigurando PowerDevil para usuarios existentes:\033[0m"
for user_dir in /home/*; do
    if [ -d "$user_dir" ]; then
        user=$(basename "$user_dir")
        config_dir="$user_dir/.config/systemd/user/plasma-powerdevil.service.d"
        override_file="$config_dir/override.conf"
        backup_file="${override_file}.bak"

        # Crear directorio si no existe
        mkdir -p "$config_dir"

        # Verificar y respaldar archivo existente
        if [ -f "$override_file" ]; then
            cp "$override_file" "$backup_file"
            echo "  ✅ Backup creado para $user: $backup_file"
        fi

        # Crear nueva configuración
        cat > "$override_file" <<EOF
[Service]
ExecStart=
ExecStart=/usr/lib/org_kde_powerdevil --no-suspend --no-hibernate
EOF

        # Corregir permisos
        chown -R "$user:$user" "$config_dir"
        echo "  ✅ Configuración aplicada para $user"
    fi
done

# 5. Configurar esqueleto para nuevos usuarios
echo -e "\n\033[1;34mConfigurando esqueleto para nuevos usuarios:\033[0m"
skel_dir="/etc/skel/.config/systemd/user/plasma-powerdevil.service.d"
mkdir -p "$skel_dir"
cat > "$skel_dir/override.conf" <<EOF
[Service]
ExecStart=
ExecStart=/usr/lib/org_kde_powerdevil --no-suspend --no-hibernate
EOF
echo "  ✅ Configuración aplicada a /etc/skel"

# 6. Recomendación final
echo -e "\n\033[1;32mREINICIA EL SISTEMA ANTES DE CONTINUAR:\033[0m"
echo "sudo reboot"
echo ""
echo "Después del reinicio:"
echo "- Verifica para cada usuario con:"
echo "  systemctl --user status plasma-powerdevil.service"
echo "- Asegúrate en 'Configuración del Sistema > Administración de energía'"
echo "  que todas las opciones de suspensión/hibernación estén desactivadas"

# Limpiar los archivos temporales
sudo rm -f "$0"
exit 0
