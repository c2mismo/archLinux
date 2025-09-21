#!/bin/bash

# Para cambiar la temperatura  desde el sistema, sin afactar
# a otros valores como el GAMMA del monitor.

# No se pudo encontrar un método confiable desde terminal en KDE Plasma 6
# para consultar el estado actual de Night Light via D-Bus.
# El comando 'qdbus6 org.kde.kglobalaccel ... toggle' funciona para controlarlo,
# pero sin verificación de estado, integrarlo al script es poco fiable.
# Tu compositor Wayland (KWin en este caso, que es parte de KDE Plasma)
# no soporta el protocolo Wayland necesario (wlr-gamma-control-unstable-v1)
# que wlsunset o wl-gammarelay necesita para funcionar.

# Solo tenemos una opción
# configurar "Luz nocturna" en "Preferncias del sistema" KDE Plasma 6 y
# usar otro atajo de teclado.

# qdbus6 org.kde.kglobalaccel /component/kwin invokeShortcut "Toggle Night Color"


# === Configuración de valores ===

# Valores para el modo DIURNO
BRILLO_DIA=100
CONTRASTE_DIA=30
ROJO_DIA=80
VERDE_DIA=80
AZUL_DIA=80
VOLUMEN_DIA=0

# Valores para el modo NOCTURNO
BRILLO_NOCHE=0
CONTRASTE_NOCHE=80
ROJO_NOCHE=50
VERDE_NOCHE=50
AZUL_NOCHE=50
VOLUMEN_NOCHE=0

# === Funciones ===

# Función para aplicar la configuración diurna
aplicar_configuracion_dia() {
    echo "Aplicando configuración DIURNA..."

    ddcutil setvcp 10 $BRILLO_DIA      # Brillo
    ddcutil setvcp 12 $CONTRASTE_DIA   # Contraste
    ddcutil setvcp 16 $ROJO_DIA        # Ganancia Rojo
    ddcutil setvcp 18 $VERDE_DIA       # Ganancia Verde
    ddcutil setvcp 1a $AZUL_DIA        # Ganancia Azul
    ddcutil setvcp 62 $VOLUMEN_DIA     # Volumen

    echo "Configuración DIURNA aplicada."
}

# Función para aplicar la configuración nocturna
aplicar_configuracion_noche() {
    echo "Aplicando configuración NOCTURNA..."
    
    ddcutil setvcp 10 $BRILLO_NOCHE      # Brillo
    ddcutil setvcp 12 $CONTRASTE_NOCHE   # Contraste
    ddcutil setvcp 16 $ROJO_NOCHE        # Ganancia Rojo
    ddcutil setvcp 18 $VERDE_NOCHE       # Ganancia Verde
    ddcutil setvcp 1a $AZUL_NOCHE        # Ganancia Azul
    ddcutil setvcp 62 $VOLUMEN_NOCHE     # Volumen

    echo "Configuración NOCTURNA aplicada."
    echo "Recuerda activar 'Luz Nocturna' en KDE para la temperatura de color deseada (2300K)."
}

# === Lógica Principal ===

# 1. Obtener el valor actual de brillo
echo "Consultando el brillo actual..."
# Capturamos la salida de getvcp 10
brillo_output=$(ddcutil getvcp 10 2>&1)

# Verificamos si el comando fue exitoso
if [[ $? -ne 0 ]]; then
    echo "Error al obtener el valor de brillo: $brillo_output"
    exit 1
fi

# Extraemos el valor actual del brillo usando sed
# La línea típica es: "VCP code 0x10 (Brightness): current value = 50, max value = 100"
brillo_actual=$(echo "$brillo_output" | sed -n 's/.*current value = *\([0-9]*\).*/\1/p')

# Verificamos si se pudo extraer el valor
if [[ -z "$brillo_actual" ]]; then
    echo "No se pudo determinar el valor actual de brillo. Salida recibida:"
    echo "$brillo_output"
    exit 1
fi

echo "Brillo actual detectado: $brillo_actual"

# 2. Tomar decisión basada en el brillo
if [[ $brillo_actual -lt 50 ]]; then
    # Si el brillo es menor a 50, se considera modo NOCHE y se cambia a DIA
    echo "El brillo es menor a 50. Cambiando a modo DIURNO."
    aplicar_configuracion_dia
else
    # Si el brillo es 50 o mayor, se considera modo DIA y se cambia a NOCHE
    echo "El brillo es 50 o mayor. Cambiando a modo NOCTURNO."
    aplicar_configuracion_noche
fi

echo "Cambio de modo completado."
