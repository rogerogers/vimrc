#!/usr/bin/env bash

set -euxo pipefail

# 安装系统依赖
# 自动识别操作系统 (Mac/Ubuntu) 并使用对应包管理器安装必要工具
# setup deps begin

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OS X - 使用 Homebrew 安装
    # 如果 brew 命令不存在，先自动安装 Homebrew
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # 将 brew 添加到当前 shell 的 PATH
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    brew install python curl git zsh ripgrep fd bat
else
    # Ubuntu/Debian - 使用 apt 安装
    sudo apt update
    sudo apt install -y python-is-python3 curl git zsh python3-pip ripgrep fd-find bat
fi

# setup deps end

# 安装 oh-my-zsh
# 检查是否已安装，避免重复安装
# setup zsh begin

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "oh-my-zsh is already installed, skipping..."
fi

# setup zsh end

# ============================================
# 工具别名
# ============================================

if ! grep -q "alias grep=rg" ~/.zshrc 2>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac - brew 安装的工具名称是标准名称
        cat << 'EOF' >> ~/.zshrc

# tools alias
alias grep=rg
alias cat=bat
alias find=fd
EOF
    else
        # Ubuntu/Debian - apt 安装的工具名称有后缀
        cat << 'EOF' >> ~/.zshrc

# tools alias
alias grep=rg
alias cat=batcat
alias find=fdfind
EOF
    fi
    echo "Added shell aliases to .zshrc"
else
    echo "Shell aliases already configured, skipping..."
fi
