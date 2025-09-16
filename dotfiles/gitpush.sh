#! /bin/bash
# -*- ENCODING: UTF-8 -*-
# Atencion: enlace duro - copia como XX~
#
# By c2mismo. Public domain.

cd $HOME/proyectos/documentos && git fetch --all && git merge origin/master --no-commit && git push -u
cd $HOME/proyectos/info && git fetch --all && git merge origin/master --no-commit && git push -u
cd $HOME/proyectos/dotfiles && git fetch --all && git merge origin/master --no-commit && git push -u
cd $HOME/proyectos/arduino/230box && git fetch --all && git merge origin/master --no-commit && git push -u
cd $HOME/proyectos/arduino/ArduMan && git fetch --all && git merge origin/master --no-commit && git push -u
## cd $HOME/proyectos/arduino/arduLibs && git fetch --all && git merge origin/master --no-commit && git push -u
cd $HOME/proyectos/arduino/ledStrip && git fetch --all && git merge origin/master --no-commit && git push -u
