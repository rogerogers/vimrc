# vimrc (AI-Era Standalone Lightweight & High-Performance)

[![Vim](https://img.shields.io/badge/Vim-9.0+-019833?logo=vim&logoColor=white)](https://www.vim.org/)
[![Neovim](https://img.shields.io/badge/Neovim-0.9+-57A143?logo=neovim&logoColor=white)](https://neovim.io/)
[![vim-plug](https://img.shields.io/badge/Plugin%20Manager-vim--plug-blue)](https://github.com/junegunn/vim-plug)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern, standalone, high-performance **Vim & Neovim** configuration.

Absorbed and modernized from `amix/vimrc` / `vimrc-fork`: **sub-millisecond startup, instant file/content search via ripgrep & fd, NERDTree sidebar, lightning code reading & review, seamless system clipboard, precision text editing, and automated fast formatting**.

## Quick Start

1. **Install system dependencies (`ripgrep`, `fd`, `bat`, `fzf`, `vim`, `neovim`)**:

   ```bash
   bash zsh.sh
   ```

2. **Run full environment setup (interactively choose 1) Vim, 2) Neovim, or 3) Both)**:

   ```bash
   zsh setup.sh
   ```

## What's Included

- **Vim & Neovim Configuration (`vimrc`)**:
  - **Dual Support**: Works identically across standard **Vim** (`~/.vimrc`) and **Neovim** (`~/.config/nvim/init.vim`)
  - **Plugin Management**: `vim-plug` with auto-bootstrapping and parallel async downloads
  - **File Tree Explorers**: **`nvim-tree.lua`** (Neovim async tree) / **`fern.vim`** (Vim async tree) + **`oil.nvim`** (buffer-based file editor)
  - **Syntax & Highlighting**: `vim-polyglot` (lazy-loaded 100+ languages)
  - **Git Workflow**: `vim-fugitive` (status & interactive blame), `vim-gitgutter`, `git-messenger.vim` (popup commit info)
  - **Precision Editing**: `vim-surround`, `vim-commentary`, `vim-repeat`, `vim-indent-object`, `vim-visual-multi`, `editorconfig`
  - **Formatters**: `ALE` with modern fast linters/fixers (`ruff`, `gofumpt`, `prettier`, `shfmt`, `rustfmt`)
  - **UI & Aesthetics**: `gruvbox` true-color scheme, `lightline.vim` statusline, hybrid relative numbers
  - **Neovim Enhancements**: Live substitution preview (`inccommand=split`), terminal escape mappings
  - **System Clipboard**: Seamless copy/paste with OS and AI assistants (`clipboard^=unnamed,unnamedplus`)
  - **Persistent Undo**: Undo history survives editor restarts (`~/.vim/temp_dirs/undodir`)
- **Zsh**: oh-my-zsh, shell aliases (`bat`, `ripgrep`, `fd`, `fzf`, `v`, `n`), and fzf key-bindings
- **Node.js**: via `fnm` (Fast Node Manager) with `pnpm`
- **Python**: via `uv` (fast Python package manager) with `ruff`
- **Rust**: via `rustup` with optional `rsproxy.cn` mirror
- **Go**: with `goimports` and `shfmt` (installed to `~/sdk/go<version>`)
- **VSCode**: editor settings (supports official VSCode, Insiders, VSCodium)
- **Git**: global gitignore configuration

## Key Mappings

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `<leader>nn` | Toggle Tree | Toggle file tree sidebar (`nvim-tree` / `fern.vim`) |
| `<leader>nf` | Locate File | Reveal current file in tree sidebar (`nvim-tree` / `fern.vim`) |
| `-` / `<leader>o` | `:Oil` | **Oil.nvim**: Edit directory like a text buffer (Neovim) |
| `<leader>O` | `:Oil --float` | **Oil.nvim**: Open floating directory editor (Neovim) |
| `<leader>f` / `<C-p>` | `:Files` | Fuzzy search files in workspace via `fd` (`Esc` to exit) |
| `<leader>g` / `<leader>rg` | `:Rg` | Full-text search across files via `ripgrep` (`Esc` to exit) |
| `<leader>b` | `:Buffers` | Switch active buffers |
| `<leader>bl` | `:BLines` | Search lines in current buffer |
| `[b` / `]b` | `:bprevious` / `:bnext` | Previous / Next buffer |
| `<leader>h` / `<leader>l` | Buffer Nav | Buffer previous / next |
| `<leader>gb` | `:Git blame` | Interactive Git Blame split (Enter on commit to inspect) |
| `<leader>gm` | `git-messenger` | Popup commit message under cursor |
| `<leader>gs` | `:Git` | Git status window (`fugitive`) |
| `<leader>gd` | `:Gdiffsplit` | Git diff split view |
| `<leader>d` | `:GitGutterToggle` | Toggle Git diff signs |
| `<leader>cf` | `:ALEFix` | Format current buffer on demand |
| `<leader><cr>` | `:nohlsearch` | Clear search highlights |
| `<C-j/k/h/l>` | Window Move | Fast window navigation |
| `*` / `#` (Visual) | Search Selection | Search selected text forwards / backwards |
| `gcc` / `gc` | Commentary | Toggle comment for line / selection |
| `cs"'` / `ds"` | Surround | Change/delete surrounding quotes/brackets |

## Optional Proxy Mirrors

During `setup.sh`, you can choose to use Chinese mirror sources for faster downloads in mainland China.
