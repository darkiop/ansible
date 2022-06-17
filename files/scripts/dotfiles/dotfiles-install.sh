#!/bin/bash

# install
dir=~/dotfiles
files="bashrc gitconfig inputrc bash_profile dircolors"

# delete old symlinks
for file in $files; do
  if [ -f ~/.$file ]; then
    echo "delete: ~/.$file"
    rm ~/.$file
  fi
done

# new symlinks for files and folders
for file in $files; do
  echo "create: ~/.$file"
  ln -s $dir/$file ~/.$file
done

# install vimrc
bash $HOME/dotfiles/modules/vimrc/install_awesome_parameterized.sh $HOME/dotfiles/modules/vimrc $USER
ln -s $HOME/dotfiles/config/my_configs.vim $HOME/dotfiles/modules/vimrc/my_configs.vim

# install tmux config
if [ -f "$HOME"/dotfiles/modules/oh-my-tmux/.tmux.conf ]; then
  ln -s "$HOME"/dotfiles/modules/oh-my-tmux/.tmux.conf "$HOME"/.tmux.conf
fi
if [ -f "$HOME"/dotfiles/config/tmux.conf.local ]; then
  ln -s "$HOME"/dotfiles/config/tmux.conf.local "$HOME"/.tmux.conf.local
fi

echo