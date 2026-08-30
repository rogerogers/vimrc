#!/usr/bin/env zsh
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# 询问是否使用国内镜像加速
USE_PROXY=""
echo "是否使用国内镜像源加速安装？(y/N): \c"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    USE_PROXY="1"
    echo "将使用国内镜像源加速"
else
    echo "使用官方源安装"
fi

export USE_PROXY

# ============================================
# fnm 和 Node.js
# ============================================

# 安装 fnm (Fast Node Manager)
if ! command -v fnm &> /dev/null; then
    curl -fsSL --proto '=https' --tlsv1.2 https://fnm.vercel.app/install | bash
else
    echo "fnm is already installed, skipping..."
fi

export PATH="$HOME/.local/share/fnm:$HOME/.fnm:$PATH"
eval "$(fnm env --shell zsh)"

fnm install --lts
fnm use lts-latest
fnm default lts-latest

npm install -g pnpm

if [[ -n "$USE_PROXY" ]]; then
    pnpm config set registry https://registry.npmmirror.com
    echo "pnpm registry set to npmmirror"
fi

# ============================================
# Python 和 uv
# ============================================

if ! command -v uv &> /dev/null; then
    curl -LsSf --proto '=https' --tlsv1.2 https://astral.sh/uv/install.sh | sh
else
    echo "uv is already installed, skipping..."
fi

export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

uv python install

if [[ -n "$USE_PROXY" ]]; then
    # uv 使用环境变量配置镜像源
    export UV_INDEX_URL="https://mirrors.aliyun.com/pypi/simple/"
    # 写入 .zshenv 持久化
    if ! grep -qF "UV_INDEX_URL" ~/.zshenv 2>/dev/null; then
        echo 'export UV_INDEX_URL="https://mirrors.aliyun.com/pypi/simple/"' >> ~/.zshenv
    fi
    echo "uv pypi index url set to aliyun"
fi

uv tool install --force ruff

# ============================================
# 安装编译工具链 (Rust 需要 C 编译器)
# ============================================

if [[ "$OSTYPE" != "darwin"* ]]; then
    sudo apt update
    sudo apt install -y build-essential
fi

# ============================================
# Rust 和 rustup
# ============================================

if [[ ! -d ~/.rustup ]]; then
    if [[ -n "$USE_PROXY" ]]; then
        export RUSTUP_DIST_SERVER="https://rsproxy.cn"
        export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
        curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh -s -- -y
    else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi
else
    echo "rustup is already installed, skipping..."
fi

export PATH="$HOME/.cargo/bin:$PATH"

# 在 .zshenv 中 source cargo env
if ! grep -qF '. "$HOME/.cargo/env' ~/.zshenv 2>/dev/null; then
    echo '' >> ~/.zshenv
    echo '# rustup' >> ~/.zshenv
    echo '. "$HOME/.cargo/env"' >> ~/.zshenv
    echo "Added cargo/env sourcing to .zshenv"
fi

if [[ -n "$USE_PROXY" ]]; then
    mkdir -p ~/.cargo
    cat > ~/.cargo/config.toml << 'EOF_CARGO'
[source.crates-io]
replace-with = 'rsproxy-sparse'
[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"
[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"
[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"
[net]
git-fetch-with-cli = true
EOF_CARGO
    echo "cargo registry set to rsproxy"
fi

# ============================================
# Go
# ============================================

GO_VERSION_LATEST=$(curl -s --proto '=https' --tlsv1.2 "https://go.dev/VERSION?m=text" | head -n1)
if [[ -z "$GO_VERSION_LATEST" ]]; then
    echo "Failed to fetch latest Go version"
    exit 1
fi
if [[ ! "$GO_VERSION_LATEST" =~ ^go[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Invalid Go version format: ${GO_VERSION_LATEST}"
    exit 1
fi
GO_INSTALL_DIR="$HOME/sdk/${GO_VERSION_LATEST}"
GO_INSTALL_NEEDED=""

if ! command -v go &> /dev/null; then
    GO_INSTALL_NEEDED="1"
else
    GO_VERSION_CURRENT=$(go version | awk '{print $3}')
    if [[ "$GO_VERSION_CURRENT" != "$GO_VERSION_LATEST" ]]; then
        echo "Go version mismatch: current=${GO_VERSION_CURRENT}, latest=${GO_VERSION_LATEST}"
        GO_INSTALL_NEEDED="1"
    else
        echo "Go ${GO_VERSION_CURRENT} is already the latest, skipping..."
    fi
fi

if [[ -n "$GO_INSTALL_NEEDED" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install go
    else
        # Linux - 安装到用户目录 ~/sdk/go<version>
        GO_TAR="${GO_VERSION_LATEST}.linux-amd64.tar.gz"

        mkdir -p "$HOME/sdk"
        curl -LO "https://dl.google.com/go/${GO_TAR}"
        tar -C "$HOME/sdk" -xzf "${GO_TAR}"

        # 如果目标目录已存在，先删除
        if [[ -d "${GO_INSTALL_DIR}" ]]; then
            rm -rf "${GO_INSTALL_DIR}"
        fi
        mv "$HOME/sdk/go" "${GO_INSTALL_DIR}"
        rm "${GO_TAR}"

        # 创建软链接 ~/sdk/go -> ~/sdk/go<version>
        ln -snf "${GO_INSTALL_DIR}" "$HOME/sdk/go"

        # 创建标准路径软链接 ~/go/bin/go 和 ~/go/bin/gofmt
        mkdir -p "$HOME/go/bin"
        ln -snf "${GO_INSTALL_DIR}/bin/go" "$HOME/go/bin/go"
        ln -snf "${GO_INSTALL_DIR}/bin/gofmt" "$HOME/go/bin/gofmt"

        # 添加到 PATH
        export PATH="$HOME/go/bin:$PATH"

        # 创建 env 文件，cargo 风格
        cat > "$HOME/go/env" << 'EOF_GO'
#!/bin/sh
case ":${PATH}:" in
    *:"$HOME/go/bin":*)
        ;;
    *)
        export PATH="$HOME/go/bin:$PATH"
        ;;
esac
EOF_GO
        chmod +x "$HOME/go/env"

        # 在 .zshenv 中 source
        if ! grep -qF '. "$HOME/go/bin/env' ~/.zshenv 2>/dev/null; then
            echo '' >> ~/.zshenv
            echo '# Go' >> ~/.zshenv
            echo '. "$HOME/go/env"' >> ~/.zshenv
            echo "Added go/env sourcing to .zshenv"
        fi

        echo "Installed ${GO_VERSION_LATEST} to ${GO_INSTALL_DIR}"
        echo "Linked go binary to $HOME/go/bin/go"
    fi
fi

if [[ -n "$USE_PROXY" ]]; then
    go env -w GOPROXY=https://goproxy.cn,direct
    echo "Go proxy set to goproxy.cn"
fi

go install golang.org/x/tools/cmd/goimports@latest
go install mvdan.cc/sh/v3/cmd/shfmt@latest

# ============================================
# Git 全局配置与软链接
# ============================================

git config --global core.excludesfile ~/.gitignore
ln -snf "${SCRIPT_DIR}/.gitignore" "$HOME/.gitignore"
echo "Linked ~/.gitignore"

# ============================================
# Vim & Neovim 配置与软链接
# ============================================

echo "请选择要配置的编辑器 [1) Vim  2) Neovim  3) Both (默认)]: \c"
read -r editor_choice

SETUP_VIM=""
SETUP_NVIM=""

case "${editor_choice}" in
    1|[Vv][Ii][Mm])
        SETUP_VIM="1"
        ;;
    2|[Nn][Vv][Ii][Mm]|[Nn]eovim)
        SETUP_NVIM="1"
        ;;
    *)
        SETUP_VIM="1"
        SETUP_NVIM="1"
        ;;
esac

# 清理旧的 amix/vimrc 运行时目录（如果存在）
if [[ -d "$HOME/.vim_runtime" ]]; then
    echo "检测到旧的 amix/vimrc 目录 (~/.vim_runtime)，是否删除释放空间? (y/N): \c"
    read -r clean_old
    if [[ "$clean_old" =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.vim_runtime"
        echo "已清理 ~/.vim_runtime"
    fi
fi

# 配置 Vim
if [[ -n "$SETUP_VIM" ]]; then
    mkdir -p "$HOME/.vim/temp_dirs/undodir"
    mkdir -p "$HOME/.vim/autoload"
    ln -snf "${SCRIPT_DIR}/vimrc" "$HOME/.vimrc"
    echo "Linked ~/.vimrc -> ${SCRIPT_DIR}/vimrc"

    if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
        curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        echo "Installed vim-plug for Vim"
    fi

    if command -v vim &> /dev/null; then
        vim +PlugInstall +PlugClean! +qall
        echo "Vim plugins installed and synchronized"
    else
        echo "Vim 未安装，跳过 Vim 插件同步"
    fi
fi

# 配置 Neovim
if [[ -n "$SETUP_NVIM" ]]; then
    mkdir -p "$HOME/.vim/temp_dirs/undodir"
    mkdir -p "$HOME/.config/nvim"
    mkdir -p "$HOME/.local/share/nvim/site/autoload"
    ln -snf "${SCRIPT_DIR}/vimrc" "$HOME/.config/nvim/init.vim"
    echo "Linked ~/.config/nvim/init.vim -> ${SCRIPT_DIR}/vimrc"

    if [[ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]]; then
        curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
            --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        echo "Installed vim-plug for Neovim"
    fi

    if command -v nvim &> /dev/null; then
        nvim --headless +PlugInstall +PlugClean! +qall
        echo "Neovim plugins installed and synchronized"
    else
        echo "Neovim 未安装，跳过 Neovim 插件同步。安装后执行 nvim --headless +PlugInstall +PlugClean! +qall 即可"
    fi
fi

# ============================================
# VSCode 配置与软链接
# ============================================

echo "是否覆盖 VSCode 配置? (y/N): \c"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    unameOut="$(uname -s)"
    case "${unameOut}" in
    Linux*) machine=Linux ;;
    Darwin*) machine=Mac ;;
    CYGWIN*) machine=Cygwin ;;
    MINGW*) machine=MinGw ;;
    MSYS_NT*) machine=MSys ;;
    *) machine="UNKNOWN:${unameOut}" ;;
    esac

    VSCODE_SETTINGS="${SCRIPT_DIR}/editors/vscode/settings.json"

    case "${machine}" in
    Mac*)
        mkdir -p "$HOME/Library/Application Support/Code/User"
        ln -snf "${VSCODE_SETTINGS}" "$HOME/Library/Application Support/Code/User/settings.json"
        echo "Linked VSCode settings for Mac"
        ;;
    Linux*)
        if [[ -d "$HOME/.config/Code/User" ]] || command -v code &> /dev/null; then
            mkdir -p "$HOME/.config/Code/User"
            ln -snf "${VSCODE_SETTINGS}" "$HOME/.config/Code/User/settings.json"
            echo "Linked VSCode settings for Linux"
        fi
        if [[ -d "$HOME/.config/Code - Insiders/User" ]]; then
            mkdir -p "$HOME/.config/Code - Insiders/User"
            ln -snf "${VSCODE_SETTINGS}" "$HOME/.config/Code - Insiders/User/settings.json"
            echo "Linked VSCode Insiders settings for Linux"
        fi
        if [[ -d "$HOME/.config/VSCodium/User" ]]; then
            mkdir -p "$HOME/.config/VSCodium/User"
            ln -snf "${VSCODE_SETTINGS}" "$HOME/.config/VSCodium/User/settings.json"
            echo "Linked VSCodium settings for Linux"
        fi
        ;;
    *) echo "Unsupported OS for VSCode settings: ${machine}" ;;
    esac
else
    echo "Skipping VSCode config"
fi

echo "Setup completed!"
