# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a vimrc configuration repository that works with [amix/vimrc](https://github.com/amix/vimrc). It contains shell scripts for setting up a complete development environment including:

- Vim configuration with vim-plug plugin manager
- Zsh setup with oh-my-zsh
- Development toolchain installation (Node.js via fnm, Python via uv, Rust, Go)
- VSCode editor configuration
- Git configuration

## Commands

### Setup

```bash
# Install system dependencies and zsh
bash zsh.sh

# Run full development environment setup
zsh setup.sh
```

## Code Architecture

### Main Scripts

| File                    | Purpose                                                                                          |
| ----------------------- | ------------------------------------------------------------------------------------------------ |
| `setup.sh`              | Main setup script - installs Node.js, Python, Rust, Go, configures Vim, VSCode, Git, Vim plugins |
| `zsh.sh`                | Installs system dependencies (bat, ripgrep, fd), zsh, oh-my-zsh, and shell aliases               |
| `config/my_configs.vim` | Custom Vim configuration that gets symlinked to amix/vimrc                                       |

### Key Features in setup.sh

- **Interactive prompt**: Asks whether to use Chinese mirror sources for faster downloads
- **Node.js**: Uses fnm (Fast Node Manager) instead of nvm
- **Python**: Uses uv for fast Python package management
- **Rust**: rustup with optional rsproxy.cn mirror
- **Go**: Auto-detects latest version from go.dev/VERSION
- **Vim**: Installs amix/vimrc + vim-plug + runs PlugInstall
- **VSCode**: Symlinks configuration files from the repo (supports official VSCode, Insiders, VSCodium)

### Idempotency Pattern

All setup scripts check if something is already installed before attempting installation. Pattern used:

```bash
if ! command -v <tool> &> /dev/null; then
    # install
fi
```

## File Organization

- `editors/vscode/` - VSCode settings.json
- `config/my_configs.vim` - Custom Vim configuration
- `config/coc-settings.json` - Vim coc.nvim LSP client config
