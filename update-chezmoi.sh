#! /bin/bash
rm -rf .local/
mkdir -p .local/share/chezmoi
chezmoi source archive -- master | tar -x -C .local/share/chezmoi
