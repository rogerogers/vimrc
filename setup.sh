set -ex

# setup ubuntu deps begin
sudo apt install -y python-is-python3 curl git zsh
# setup ubuntu deps end

# setup nvm and node begin
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

source ~/.zshrc

nvm install --lts
npm install -g pnpm yarn
# setup nvm and node end

# setup python deps begin
python -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
pip install --user ruff poetry pipenv
# setup python deps end

# setup golang begin
go install golang.org/x/tools/cmd/goimports@latest
# setup golang end

# setup rust begin
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# setup rust end
