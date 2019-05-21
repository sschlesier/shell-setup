#! /bin/bash
CMDIR=$HOME/src/shell-setup/.local/share/chezmoi
rm -rf $CMDIR
mkdir -p $CMDIR
cd $HOME/.local/share/chezmoi
git archive master | tar -x -C $CMDIR
