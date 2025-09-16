#! /bin/bash
# -*- ENCODING: UTF-8 -*-
# Atencion: enlace duro - copia como XX~
#
# By c2mismo. Public domain.

echo
echo "                     *** documentos ***"
echo
cd $HOME/proyectos/documentos && git status
echo
echo "                      Fin documentos"

echo
echo "                     *** info ***"
echo
cd $HOME/proyectos/info && git status
echo
echo "                      Fin info"

echo
echo "                     *** dotfiles ***"
echo
cd $HOME/proyectos/dotfiles && git status
echo
echo "                      Fin dotfiles"

echo
echo "                     *** 230box ***"
echo
cd $HOME/proyectos/arduino/230box && git status
echo
echo "                       Fin 230box"

echo
echo "                     *** ArduMan ***"
echo
cd $HOME/proyectos/arduino/ArduMan && git status
echo
echo "                       Fin ArduMan"

echo
echo "                     *** arduLibs ***"
echo
cd $HOME/proyectos/arduino/arduLibs && git status
echo
echo "                       Fin arduLibs"
echo

echo
echo "                     *** ledStrip ***"
echo
cd $HOME/proyectos/arduino/ledStrip && git status
echo
echo "                       Fin ledStrip"
echo
