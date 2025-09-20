#!/bin/bash

# Variables
dir="${HOME}/dotfiles"
files=(bashrc gitconfig inputrc bash_profile dircolors)

# Delete old symlinks
for file in "${files[@]}"; do
  target="${HOME}/.${file}"
  if [[ -f "${target}" || -L "${target}" ]]; then
    echo "Deleting: ${target}"
    rm -- "${target}"
  fi
done

# Create new symlinks
for file in "${files[@]}"; do
  target="${HOME}/.${file}"
  echo "Creating: ${target}"
  ln -s -- "${dir}/${file}" "${target}"
done

# Install vimrc
vimrc_script="${dir}/modules/vimrc/install_awesome_parameterized.sh"
if [[ -x "${vimrc_script}" ]]; then
  "${vimrc_script}" "${dir}/modules/vimrc" "${USER}"
  ln -sf -- "${dir}/config/my_configs.vim" "${dir}/modules/vimrc/my_configs.vim"
else
  echo "Error: ${vimrc_script} not found or not executable." >&2
fi

# Install tmux config
oh_my_tmux_conf="${dir}/modules/oh-my-tmux/.tmux.conf"
tmux_conf_local="${dir}/config/tmux.conf.local"

if [[ -f "${oh_my_tmux_conf}" ]]; then
  ln -sf -- "${oh_my_tmux_conf}" "${HOME}/.tmux.conf"
else
  echo "Error: ${oh_my_tmux_conf} not found." >&2
fi

if [[ -f "${tmux_conf_local}" ]]; then
  ln -sf -- "${tmux_conf_local}" "${HOME}/.tmux.conf.local"
else
  echo "Error: ${tmux_conf_local} not found." >&2
fi
