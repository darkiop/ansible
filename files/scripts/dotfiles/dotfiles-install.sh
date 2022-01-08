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

# byobu config
if [ -L ~/.byobu ] ; then
  if [ ! -e ~/.byobu ] ; then
      # remove > broken
      rm ~/.byobu
      echo -e $COLOR_GREEN"create"$COLOR_CLOSE$COLOR_YELLOW" .byobu "$COLOR_GREEN"symlink ..."$COLOR_CLOSE
      echo "create: ~/.byobu"
      ln -s ~/dotfiles/config/byobu ~/.byobu
  fi
else
  # link not exist
  echo -e $COLOR_GREEN"create"$COLOR_CLOSE$COLOR_YELLOW" .byobu "$COLOR_GREEN"symlink ..."$COLOR_CLOSE
  echo "create: ~/.byobu"
  ln -s ~/dotfiles/config/byobu ~/.byobu
fi

# install vimrc
bash $HOME/dotfiles/modules/vimrc/install_awesome_parameterized.sh $HOME/dotfiles/modules/vimrc $USER

echo