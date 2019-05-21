#! /bin/bash

cd $HOME/.local/share/chezmoi
git archive master | tar -x -C $HOME/src/shell-setup/.local/share/chezmoi
