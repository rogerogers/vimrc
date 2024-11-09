#!/usr/bin/env sh
set -ex

if [[ ! -d ~/.vim_runtime ]]; then
	git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
	sh ~/.vim_runtime/install_awesome_vimrc.sh
	echo "Installed vimrc"
fi

# vimrc
ln -snf $(pwd)/my_configs.vim $HOME/.vim_runtime/my_configs.vim

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# global gitignore
git config --global core.excludesFile '~/.gitignore'
ln -snf $(pwd)/.gitignore ~/.gitignore

unameOut="$(uname -s)"
case "${unameOut}" in
Linux*) machine=Linux ;;
Darwin*) machine=Mac ;;
CYGWIN*) machine=Cygwin ;;
MINGW*) machine=MinGw ;;
MSYS_NT*) machine=MSys ;;
*) machine="UNKNOWN:${unameOut}" ;;
esac

case "${machine}" in
Mac*)
	ln -snf $(pwd)/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
	;;
*) echo "unsupported os" ;;
esac
