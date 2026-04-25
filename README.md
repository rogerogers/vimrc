# vimrc

vimrc work with <https://github.com/amix/vimrc>
add vim-plug and some self use plugin

## Usage

1. Install system dependencies and zsh:

   ```bash
   bash zsh.sh
   ```

2. Run full development environment setup:

   ```bash
   zsh setup.sh
   ```

## What's Included

- **Zsh** with oh-my-zsh and shell aliases (bat, ripgrep, fd)
- **Node.js** via fnm (Fast Node Manager) with pnpm
- **Python** via uv (fast Python package manager) with ruff
- **Rust** via rustup with optional rsproxy.cn mirror
- **Go** with goimports and shfmt (installed to `~/sdk/go<version>`)
- **Vim** configuration with amix/vimrc + vim-plug
- **VSCode** editor settings (supports official VSCode, Insiders, VSCodium)
- **Git** global gitignore configuration

## Optional Proxy Mirrors

During `setup.sh`, you can choose to use Chinese mirror sources for faster downloads in mainland China.
