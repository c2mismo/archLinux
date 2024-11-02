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

# Verificar espacio en disco
print_section "Espacio en disco"
df -h

# Verificar uso de memoria
print_section "Uso de memoria"
free -h

# Verificar paquetes huérfanos
print_section "Paquetes huérfanos"
pacman -Qtd

# Verificar paquetes foráneos (no en los repositorios oficiales)
print_section "Paquetes foráneos"
pacman -Qm

# Verificar archivos pacnew y pacsave
print_section "Archivos pacnew y pacsave"
find /etc -name "*.pacnew" -o -name "*.pacsave"

# Verificar errores de pacman
print_section "Errores recientes de pacman"
grep -i "error\|warning" /var/log/pacman.log | tail -n 20

# Verificar integridad de los paquetes
print_section "Verificación de integridad de paquetes"
pacman -Qk

# Verificar si hay actualizaciones pendientes
print_section "Actualizaciones pendientes"
checkupdates

echo -e "\nFin del diagnóstico del sistema"
