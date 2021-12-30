#!/bin/bash

# install
dir=~/dotfiles
files="bashrc gitconfig inputrc bash_profile dircolors"
folders="byobu"

# delete old symlinks
for file in $files; do
  if [ -f ~/.$file ]; then
    echo "delete: ~/.$file"
    rm ~/.$file
  fi
done
for folder in $folders; do
  if [ -d ~/.$folder ]; then
    echo "delete: ~/.$folder";
    rm -r ~/.$folder
  fi
done

# new symlinks for files and folders
for file in $files; do
  echo "create: ~/.$file"
  ln -s $dir/$file ~/.$file
done
for folder in $folders; do
  echo "create: ~/.$folder"
  ln -s $dir/$folder ~/.$folder
done