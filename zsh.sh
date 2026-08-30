#!/usr/bin/env bash

set -euxo pipefail

# ============================================
# 询问选择安装的编辑器 (Vim / Neovim / Both)
# ============================================

echo "请选择要安装的编辑器 [1) Vim  2) Neovim  3) Both (默认)]: \c"
read -r editor_choice || editor_choice=""

PACKAGES_MAC=("python" "curl" "git" "zsh" "ripgrep" "fd" "bat" "fzf")
PACKAGES_LINUX=("python-is-python3" "curl" "git" "zsh" "python3-pip" "ripgrep" "fd-find" "bat" "fzf")
INSTALL_MODE="both"

case "${editor_choice}" in
    1|[Vv][Ii][Mm])
        PACKAGES_MAC+=("vim")
        PACKAGES_LINUX+=("vim")
        INSTALL_MODE="vim"
        ;;
    2|[Nn][Vv][Ii][Mm]|[Nn]eovim)
        PACKAGES_MAC+=("neovim")
        PACKAGES_LINUX+=("neovim")
        INSTALL_MODE="nvim"
        ;;
    *)
        PACKAGES_MAC+=("vim" "neovim")
        PACKAGES_LINUX+=("vim" "neovim")
        INSTALL_MODE="both"
        ;;
esac

# ============================================
# 安装系统依赖
# ============================================

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OS X - 使用 Homebrew 安装
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    brew install "${PACKAGES_MAC[@]}"
else
    # Ubuntu/Debian - 使用 apt 安装
    sudo apt update
    sudo apt install -y "${PACKAGES_LINUX[@]}"
fi

# ============================================
# 安装 oh-my-zsh
# ============================================

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "oh-my-zsh is already installed, skipping..."
fi

# ============================================
# 工具别名与 FZF Shell 集成
# ============================================

if ! grep -q "alias grep=rg" ~/.zshrc 2>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        cat << 'EOF' >> ~/.zshrc

# tools alias
alias grep=rg
alias cat=bat
alias find=fd
EOF
    else
        cat << 'EOF' >> ~/.zshrc

# tools alias
alias grep=rg
alias cat=batcat
alias find=fdfind
EOF
    fi

    if [[ "$INSTALL_MODE" == "nvim" ]]; then
        cat << 'EOF' >> ~/.zshrc
alias v=nvim
alias vi=nvim
alias vim=nvim
alias n=nvim
EOF
    elif [[ "$INSTALL_MODE" == "vim" ]]; then
        cat << 'EOF' >> ~/.zshrc
alias v=vim
alias vi=vim
alias n=vim
EOF
    else
        cat << 'EOF' >> ~/.zshrc
alias v=vim
alias vi=vim
alias n=nvim
EOF
    fi
    echo "Added shell aliases to .zshrc"
else
    echo "Shell aliases already configured, skipping..."
fi

# FZF 键位绑定与补全集成 (Ctrl-T, Ctrl-R, Alt-C, **<Tab>)
if ! grep -q "fzf --zsh" ~/.zshrc 2>/dev/null; then
    cat << 'EOF' >> ~/.zshrc

# fzf integration
if command -v fzf &> /dev/null; then
    if fzf --zsh &>/dev/null; then
        eval "$(fzf --zsh)"
    elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
        source /usr/share/doc/fzf/examples/completion.zsh
    elif [[ -d /opt/homebrew/opt/fzf/shell ]]; then
        source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
        source /opt/homebrew/opt/fzf/shell/completion.zsh
    fi
fi
EOF
    echo "Added fzf shell integration to .zshrc"
else
    echo "fzf integration already configured, skipping..."
fi
