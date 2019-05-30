#! /bin/bash
rm -rf home/.local/
mkdir -p home/.local/share/chezmoi
chezmoi source archive -- master | tar -x -C home/.local/share/chezmoi
