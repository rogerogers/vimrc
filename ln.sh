#!/usr/bin/env sh
set -ex

git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

ln -s $(pwd)/my_configs.vim $HOME/.vim_runtime/my_configs.vim
