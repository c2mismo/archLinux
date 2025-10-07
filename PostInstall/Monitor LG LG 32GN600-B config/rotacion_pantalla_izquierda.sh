#!/bin/bash

# Script para alternar rotación de pantalla entre "normal" y "left" en KDE Wayland
# Usando kscreen-doctor

# Detectar automáticamente la primera pantalla conectada
OUTPUT_NAME=$(kscreen-doctor -o | sed 's/\x1b\[[0-9;]*m//g' | grep "Output:" | head -1 | awk '{print $3}')

# Verificar que se detectó una pantalla
if [ -z "$OUTPUT_NAME" ]; then
    echo "Error: No se pudo detectar una pantalla externa."
    exit 1
fi

echo "Pantalla detectada: $OUTPUT_NAME"

# Obtener la rotación actual de la pantalla especificada
rotation=$(kscreen-doctor -o | sed 's/\x1b\[[0-9;]*m//g' | sed -n "/Output:.*$OUTPUT_NAME/,/Output:/p" | grep "Rotation:" | awk '{print $2}')

# Verificar si se obtuvo la rotación
if [ -z "$rotation" ]; then
    echo "Error: No se pudo obtener la rotación de $OUTPUT_NAME. Verifica que la pantalla esté conectada."
    exit 1
fi

# Alternar rotación
if [ "$rotation" -eq 1 ]; then
    echo "Rotación actual: normal (none). Cambiando a left."
    kscreen-doctor output.$OUTPUT_NAME.rotation.left
elif [ "$rotation" -eq 2 ]; then
    echo "Rotación actual: left. Cambiando a normal (none)."
    kscreen-doctor output.$OUTPUT_NAME.rotation.none
else
    echo "Error: Rotación desconocida: $rotation. Solo se soporta alternancia entre normal (1) y left (2)."
    exit 1
fi

echo "Cambio de rotación aplicado."
