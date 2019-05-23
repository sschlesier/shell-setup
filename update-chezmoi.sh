#! /bin/bash
TARGET=$(realpath .local/share/chezmoi)
find $TARGET -mindepth 1 -delete 
chezmoi source archive master | tar -x -C $TARGET
