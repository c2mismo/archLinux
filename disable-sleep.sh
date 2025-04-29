#!/bin/bash
# Desabilitamos la hibernación,
# obligatorio si queremos tener una
# swap volatil

# Este comando es efectivo para deshabilitar la suspensión, la hibernación y
# el sueño híbrido a nivel de systemd. Al "enmascarar" estos objetivos,
# impides que el sistema pueda entrar en cualquiera de estos estados,
# lo que es una solución rápida y directa.
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Esto proporciona una configuración adicional que refuerza la política de suspensión.
Aunque el comando mask debería ser suficiente, agregar estas configuraciones
puede ser útil si deseas tener un control más granular sobre el comportamiento
de suspensión.

mkdir /etc/systemd/sleep.conf.d
o
nano /etc/systemd/sleep.conf.d/99-nopower.conf
con:
[Sleep]
AllowSuspend=no
AllowHibernation=no
AllowHybridSleep=no
AllowSuspendThenHibernate=no

# Esto es útil si deseas asegurarte de que las teclas de energía no activen
# la suspensión o la hibernación. Cambiar estas configuraciones es una buena
# práctica si utilizas un entorno donde podrías presionar accidentalmente estas teclas.

nano /etc/systemd/logind.conf

#HandlePowerKey=ignore
HandlePowerKey=ignore

#HandlePowerKeyLongPress=poweroff
HandlePowerKeyLongPress=poweroff

#HandleHibernateKey=hibernate
HandleHibernateKey=ignore

#HandleHibernateKeyLongPress=ignore
HandleHibernateKeyLongPress=ignore

#HandleSuspendKeyLongPress=hibernate
HandleSuspendKeyLongPress=ignore

#HibernateKeyIgnoreInhibited=no
HibernateKeyIgnoreInhibited=no

sudo systemctl restart systemd-logind





Configuración de Energía en Plasma:

    Abre Configuración del sistema.
    Ve a Administración de energía.
    En las secciones de Suspensión y Hibernación, asegúrate de que las opciones para suspender al cerrar la tapa o al inactividad estén desactivadas. Esto evitará que el sistema entre en suspensión automáticamente.

sudo find /usr/lib -name powerdevil
/usr/lib/qt6/plugins/powerdevil
/usr/lib/org_kde_powerdevil


systemctl --user edit plasma-powerdevil.service

### Editing /home/c2mismo/.config/systemd/user/plasma-powerdevil.service.d/override.conf
### Anything between here and the comment below will become the contents of the drop-in file

[Service]
ExecStart=
ExecStart=/usr/lib/org_kde_powerdevil --no-suspend --no-hibernate

### Edits below this comment will be discarded


### /usr/lib/systemd/user/plasma-powerdevil.service
# [Unit]
# Description=Powerdevil
# PartOf=graphical-session.target
# After=plasma-core.target
#
# [Service]
# ExecStart=/usr/lib/org_kde_powerdevil
# Type=dbus
# BusName=org.kde.Solid.PowerManagement
# TimeoutStopSec=5sec
# Slice=background.slice
# Restart=on-failure

systemctl --user edit plasma-powerdevil.service

[Service]
ExecStart=
ExecStart=/usr/lib/org_kde_powerdevil --no-suspend --no-hibernate

systemctl --user daemon-reload

systemctl --user restart plasma-powerdevil.service

Verifity
systemctl --user status plasma-powerdevil.service
journalctl --user -xeu plasma-powerdevil.service

[c2mismo@archi9 ~]$ /usr/lib/org_kde_powerdevil
org.kde.powerdevil: [DDCutilDetector]: Failed to initialize callback
org.kde.powerdevil: org.kde.powerdevil.chargethresholdhelper.getthreshold failed "Charge thresholds are not supported by the kernel for this hardware"
org.kde.powerdevil: org.kde.powerdevil.backlighthelper.brightness failed
org.kde.powerdevil: Handle button events action could not check for screen configuration
org.kde.powerdevil: org.kde.powerdevil.chargethresholdhelper.getthreshold failed "Charge thresholds are not supported by the kernel for this hardware"

DDCutilDetector: Failed to initialize callback:

    Este error sugiere que PowerDevil está intentando utilizar DDC/CI para controlar la configuración del monitor, pero no puede inicializar el callback necesario. Esto puede ser un problema de compatibilidad con tu hardware o con la configuración del sistema.

Charge thresholds are not supported by the kernel for this hardware:

    Este mensaje indica que el kernel de Linux no soporta los umbrales de carga para tu hardware específico. Esto puede ser común en ciertos modelos de laptops o hardware que no implementa esta funcionalidad.

Backlighthelper.brightness failed:

    Este error sugiere que PowerDevil no puede acceder o controlar el brillo de la pantalla. Esto puede deberse a la falta de controladores adecuados o a problemas de permisos.

Handle button events action could not check for screen configuration:

    Este mensaje indica que PowerDevil no puede verificar la configuración de la pantalla, lo que puede afectar la gestión de energía y la respuesta a eventos como el cierre de la tapa.


+++++++++++++++++++++++++++++++++++++++++
Soluciones
Si tu monitor es compatible, puedes intentar instalar ddcutil, que es una herramienta para controlar monitores a través de DDC/CI. Esto puede ayudar a resolver el problema de inicialización:

este no lo haremos si no es necesario:
sudo usermod -aG input c2mismo

++++++++++++++++++++++++++++++++++++++++++

1.- el cable es DP2.0
2.- el monitor no tiene la opcion en OSD de desabilitar DDC/CI
3.- [c2mismo@archi9 ~]$ ddcutil detect
Display 1 I2C bus: /dev/i2c-5 DRM connector: card1-DP-2 EDID synopsis: Mfg id: GSM - Goldstar Company Ltd (LG) Model: LG ULTRAGEAR Product code: 30566 (0x7766) Serial number: 311MAJMFZ676 Binary serial number: 1846876 (0x001c2e5c) Manufacture year: 2023, Week: 11 VCP version: 2.1

Intenta usar ddcutil para ajustar el brillo o el contraste del monitor directamente. Por ejemplo:
ddcutil setvcp 10 90  # Ajusta el brillo al 50%
ddcutil getvcp 10     # Obtiene el valor actual del brillo


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
EOF

cat /etc/systemd/sleep.conf.d
echo ""
echo "Desabilitada la hibernación"

# Limpiar los archivos temporales
sudo rm -f "$0"
