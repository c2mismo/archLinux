#!/bin/bash

echo "Script de diagnóstico del sistema para Arch Linux"
echo "================================================"

# Función para imprimir secciones
print_section() {
    echo -e "\n--- $1 ---"
}

# Verificar servicios systemd fallidos
print_section "Servicios systemd fallidos"
systemctl --failed

# Buscar errores en el journal de systemd
print_section "Errores recientes en el journal de systemd"
journalctl -p 3 -xb --no-pager | tail -n 20

# Verificar paquetes huérfanos
print_section "Paquetes huérfanos"
pacman -Qtd

# Verificar archivos pacnew y pacsave
print_section "Archivos pacnew y pacsave"
pacnew_pacsave=$(sudo find /etc -name "*.pacnew" -o -name "*.pacsave")
if [ -z "$pacnew_pacsave" ]; then
    echo "No se encontraron archivos .pacnew o .pacsave en /etc."
else
    echo "Se encontraron los siguientes archivos .pacnew o .pacsave:"
    echo "$pacnew_pacsave"
    echo -e "\nNúmero total de archivos encontrados: $(echo "$pacnew_pacsave" | wc -l)"
fi


# Verificar errores de pacman
print_section "Errores recientes de pacman"
pacman_errors=$(grep -i "error\|warning" /var/log/pacman.log | tail -n 20)
if [ -z "$pacman_errors" ]; then
    echo "No se encontraron errores recientes de pacman."
else
    echo "Se encontraron los siguientes errores o advertencias recientes de pacman:"
    echo "$pacman_errors"
    echo -e "\nNúmero total de errores/advertencias encontrados: $(echo "$pacman_errors" | wc -l)"
fi


# Verificar integridad de los paquetes
print_section "Verificación de integridad de paquetes"
integrity_check=$(sudo pacman -Qk 2>&1)
if echo "$integrity_check" | grep -q "0 missing files"; then
    echo "Todos los paquetes están íntegros."
else
    echo "Se encontraron paquetes con problemas de integridad:"
    echo "$integrity_check" | grep -v "0 missing files"
fi

# Verificar si hay actualizaciones pendientes
print_section "Actualizaciones pendientes"
updates=$(checkupdates)
if [ -z "$updates" ]; then
    echo "No hay actualizaciones pendientes. El sistema está al día."
else
    echo "Hay actualizaciones pendientes:"
    echo "$updates"
    echo -e "\nNúmero total de actualizaciones pendientes: $(echo "$updates" | wc -l)"
fi


echo -e "\nFin del diagnóstico del sistema"
exit 0
