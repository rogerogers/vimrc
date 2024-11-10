set -ex
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
