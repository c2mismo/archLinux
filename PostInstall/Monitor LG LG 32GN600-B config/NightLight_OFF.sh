#!/bin/bash

# Suspender/Reanudar Night Light omitido.
# No se pudo encontrar un método confiable desde terminal en KDE Plasma 6
# para consultar el estado actual de Night Light via D-Bus.
# El comando 'qdbus6 org.kde.kglobalaccel ... toggle' funciona para controlarlo,
# pero sin verificación de estado, integrarlo al script es poco fiable.
# Tu compositor Wayland (KWin en este caso, que es parte de KDE Plasma)
# no soporta el protocolo Wayland necesario (wlr-gamma-control-unstable-v1)
# que wlsunset o wl-gammarelay necesita para funcionar.

# Brillo (0-100)
ddcutil setvcp 10 100

# Contraste (0-100)
ddcutil setvcp 12 30

# Ganancia de Rojo (0-100)
ddcutil setvcp 16 80

# Ganancia de Verde (0-100)
ddcutil setvcp 18 80

# Ganancia de Azul (0-100)
ddcutil setvcp 1a 80

# Volumen del altavoz (0-100)
ddcutil setvcp 62 0

# Presets de Color (6500 K)
# Luz diurna fría (pantalla normal)
# no modificar mantener este valor.
#
# Tener encuenta que al cambiar las ganancias
# se modifica este valor a User
# por eso es importante ejecutarlo la final
# ddcutil setvcp 14 0x05

# Presets de Color nocturno (2300 K) configurado en KDE Plasma 6
# Ejecutarlo con un atajo de teclado

# Para cambiar la temperatura  desde el sistema, sin afactar
# a otros valores como el GAMMA del monitor, solo tenemos una opción
# configurar "Luz nocturna" en "Preferncias del sistema" KDE Plasma 6 y
# usar otro atajo de teclado.

# qdbus6 org.kde.kglobalaccel /component/kwin invokeShortcut "Toggle Night Color"
