# AGENTS.md

This file provides context and operational guidelines for autonomous AI agents and coding assistants (Antigravity, Claude Code, Cursor, Copilot, Codex) working within this repository.

## Repository Purpose

This is a modern, standalone, high-performance **Vim & Neovim** configuration repository managed with [vim-plug](https://github.com/junegunn/vim-plug). It provides shell scripts and dotfiles for bootstrapping a complete AI-era development environment, including:

- Standalone, lightweight Vim & Neovim configuration (`vimrc`)
- Zsh setup with oh-my-zsh and modern CLI tools (`fzf`, `ripgrep`, `fd`, `bat`, `vim`, `neovim`)
- Fast toolchain installation (Node.js via fnm, Python via uv, Rust via rustup, Go)
- VSCode editor settings (`editors/vscode/settings.json`)
- Global Git ignore configuration (`.gitignore`)

## Setup & Maintenance Commands

```bash
# 1. Install system dependencies and zsh
bash zsh.sh

# 2. Run full development environment setup (interactive: 1) Vim, 2) Neovim, 3) Both)
zsh setup.sh
```

## Architecture & File Organization

| Path                     | Purpose                                                                                             |
| ------------------------ | --------------------------------------------------------------------------------------------------- |
| `vimrc`                  | Core standalone Vim/Neovim configuration (symlinked to `~/.vimrc` and `~/.config/nvim/init.vim`)   |
| `setup.sh`               | Main orchestration script for toolchains, symlinks, and plugin synchronization                      |
| `zsh.sh`                 | System package installer and shell customization script                                             |
| `editors/vscode/`        | VSCode / VSCodium configuration (`settings.json`)                                                   |
| `.gitignore`             | Global gitignore template (symlinked to `~/.gitignore`)                                            |
| `AGENTS.md` / `CLAUDE.md`| AI coding assistant developer documentation                                                         |

## Key Script Design Principles

1. **Idempotency**: All setup scripts must safely handle re-runs. Use `command -v <tool>` guards and `ln -snf` for symlinks.
2. **Dual Vim & Neovim Compatibility**: The `vimrc` file is shared by both Vim and Neovim without bifurcation.
3. **Sub-ms Startup & Zero Bloat**: No heavy node daemons in Vim. Fast tools (`fzf`, `ripgrep`, `fd`, `ruff`, `gofumpt`) do the heavy lifting in background.
4. **Proxy & Mirror Support**: `setup.sh` supports optional Chinese mirrors (aliyun, rsproxy, goproxy) for faster domestic downloads.
