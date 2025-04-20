#!/bin/bash

set -ex
# 使用 uname -s 命令获取操作系统名称
os_name=$(uname -s)

function setup_ubuntu() {
    sudo apt install -y bat ripgrep fd-find
    if rg -q "alias grep" ~/.zshrc; then
        echo 'already setup'
    else
        batcat <<EOF >>~/.zshrc

# tools alias v0.0.1
alias grep=rg
alias cat=batcat
alias find=fdfind

EOF
fi
}

function setup_mac() {
    brew install bat ripgrep fd
    if rg -q "alias grep" ~/.zshrc; then
        echo 'already setup'
    else
        bat <<EOF >>~/.zshrc

# tools alias v0.0.1
alias grep=rg
alias cat=bat
alias find=fd

EOF
fi
}

# 根据输出结果进行判断
if [ "$os_name" = "Linux" ]; then
    setup_ubuntu
elif [ "$os_name" = "Darwin" ]; then
    setup_mac
else
    echo "当前系统既不是 Linux 也不是 Mac，系统名称为: $os_name"
fi

