#!/usr/bin/env zsh
set -ex

# setup nvm and node begin
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

source ~/.zshrc

nvm install --lts
npm install -g pnpm yarn
# setup nvm and node end

# setup python deps begin
# python -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
# pip install --user ruff poetry pipenv
# setup python deps end

# setup git
git config --global core.excludesfile ~/.gitignore
cp .gitignore ~/.gitignore
# setup git

# setup golang begin
go install golang.org/x/tools/cmd/goimports@latest
go install mvdan.cc/sh/v3/cmd/shfmt@latest
# setup golang end

# setup rust begin
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# setup rust end
