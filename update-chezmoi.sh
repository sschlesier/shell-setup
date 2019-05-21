#! /bin/bash

chezmoi cd
git archive master | tar -x -C $HOME/src/shell-setup/.local/share/chezmoi
exit
