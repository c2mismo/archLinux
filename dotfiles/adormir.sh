#!/bin/bash

cancel() { shutdown -c && echo "Aqui nadie se vá a dormir" || echo "ERROR desconocido"; }

## Comprobamos que es numérico y mayor que 0

if [ "$1" -eq "$1" ] 2>/dev/null; then
	if [ "$1" -gt 0 ]; then
		shutdown -P $1 && exit 0
	fi
fi


echo "Tipea C o 0 para cancelar o los minutos a los que quieres apagar el pc"
read TIME

if [ "$TIME" -eq "$TIME" ] 2>/dev/null; then
	if [ "$TIME" -eq "0" ]; then
		cancel
	elif [ "$TIME" -gt "0" ]; then
		shutdown -P $TIME && exit 0
	fi

elif [ "$TIME" = "C" ]; then
	cancel

elif [ "$TIME" = "c" ]; then
	cancel

else
	echo "ERROR por favor tipea una opción correcta." && exit 1

fi
