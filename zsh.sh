#!/usr/bin/env bash

set -ex

# setup ubuntu deps begin
sudo apt install -y python-is-python3 curl git zsh python3-pip
# setup ubuntu deps end

# setup zsh begin
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# setup zsh end
