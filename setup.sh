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
    # 写入 .zshrc 持久化
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

# 在 .zshrc 中 source cargo env
if ! grep -qF '. "$HOME/.cargo/env' ~/.zshenv 2>/dev/null; then
    echo '' >> ~/.zshenv
    echo '# rustup' >> ~/.zshenv
    echo '. "$HOME/.cargo/env"' >> ~/.zshenv
    echo "Added cargo/env sourcing to .zshrc"
fi

if [[ -n "$USE_PROXY" ]]; then
    mkdir -p ~/.cargo
    cat > ~/.cargo/config.toml << 'EOF'
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
EOF
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
        cat > "$HOME/go/env" << 'EOF'
#!/bin/sh
case ":${PATH}:" in
    *:"$HOME/go/bin":*)
        ;;
    *)
        export PATH="$HOME/go/bin:$PATH"
        ;;
esac
EOF
        chmod +x "$HOME/go/env"

        # 在 .zshrc 中 source
        if ! grep -qF '. "$HOME/go/bin/env' ~/.zshenv 2>/dev/null; then
            echo '' >> ~/.zshenv
            echo '# Go' >> ~/.zshenv
            echo '. "$HOME/go/env"' >> ~/.zshenv
            echo "Added go/bin/env sourcing to .zshrc"
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
# Git 配置
# ============================================

git config --global core.excludesfile ~/.gitignore

# 先删除再创建，避免符号链接循环
rm -f ~/.gitignore
ln -s "${SCRIPT_DIR}/.gitignore" ~/.gitignore

# ============================================
# Vim 配置
# ============================================

if [[ ! -d ~/.vim_runtime ]]; then
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
    echo "Installed vimrc"
else
    echo "vimrc is already installed, skipping clone..."
fi

echo "是否覆盖 Vim 自定义配置 (my_configs.vim)? (y/N): \c"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    ln -snf "${SCRIPT_DIR}/config/my_configs.vim" "$HOME/.vim_runtime/my_configs.vim"
    echo "Vim config updated"
else
    echo "Skipping Vim config"
fi

if [[ ! -f ~/.vim/autoload/plug.vim ]]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo "Installed vim-plug"
else
    echo "vim-plug is already installed, skipping download..."
fi

vim +PlugInstall +qall
echo "Vim plugins installed"

# ============================================
# VSCode 配置
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
        if [[ -d ~/Library/Application\ Support/Code/User ]]; then
            ln -snf "${VSCODE_SETTINGS}" ~/Library/Application\ Support/Code/User/settings.json
            echo "Linked VSCode settings for Mac"
        else
            echo "VSCode config directory not found, please install VSCode first"
        fi
        ;;
    Linux*)
        if [[ -d ~/.config/Code/User ]]; then
            ln -snf "${VSCODE_SETTINGS}" ~/.config/Code/User/settings.json
            echo "Linked VSCode settings for Linux"
        elif [[ -d ~/.config/Code\ -\ Insiders/User ]]; then
            ln -snf "${VSCODE_SETTINGS}" ~/.config/Code\ -\ Insiders/User/settings.json
            echo "Linked VSCode Insiders settings for Linux"
        elif [[ -d ~/.config/VSCodium/User ]]; then
            ln -snf "${VSCODE_SETTINGS}" ~/.config/VSCodium/User/settings.json
            echo "Linked VSCodium settings for Linux"
        else
            echo "VSCode config directory not found, please install VSCode first"
        fi
        ;;
    *) echo "Unsupported OS for VSCode settings: ${machine}" ;;
    esac
else
    echo "Skipping VSCode config"
fi

echo "Setup completed!"
