curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

source ~/.zshrc

nvm install --lts
npm install -g pnpm yarn

# pnpm registry
pnpm config set registry https://registry.npmmirror.com
