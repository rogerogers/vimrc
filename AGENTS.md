# AI Agent Guidelines

This repository contains development environment configuration scripts (dotfiles/setup scripts) intended to automate the installation and configuration of developer tools (Zsh, Node.js, Python, Rust, Go, Vim, VSCode) across different machines.

When assisting with this repository, please adhere to the following guidelines:

## 1. Cross-Platform Compatibility
- The scripts (like `setup.sh` and `zsh.sh`) should primarily support macOS (Darwin) and Linux (especially Debian/Ubuntu-based distributions).
- Always use conditional checks (e.g., `if [[ "$OSTYPE" == "darwin"* ]]`) when performing OS-specific operations, such as installing packages via `brew` vs `apt`.

## 2. Proxy and Mirrors (`$USE_PROXY`)
- This repository supports an optional domestic proxy/mirror feature for users in mainland China.
- When adding support for a new programming language, package manager, or tool, always check if `$USE_PROXY` is enabled.
- If `$USE_PROXY` is set, configure the tool to use a reliable Chinese mirror source (e.g., Aliyun, rsproxy, goproxy.cn, npmmirror) to speed up downloads.

## 3. Shell Script Best Practices
- **Strict Mode**: Ensure bash/zsh scripts start with `set -euo pipefail` to catch errors early.
- **Idempotency**: Scripts should be safe to run multiple times. Check if a tool or directory already exists before downloading or installing (e.g., `if ! command -v tool &> /dev/null; then ...`).
- **Formatting**: Shell scripts should ideally be formatted. Avoid trailing spaces and use consistent indentation (4 spaces or 2 spaces depending on the existing code, default here is 4 spaces).
- Ensure safe file handling. When creating symbolic links, use `ln -snf` to overwrite existing links safely without creating recursive loops.

## 4. Modifying Tool Configurations
- **Zsh**: Global environment variables should be injected into `~/.zshenv`, while interactive configurations go into `~/.zshrc`.
- **VSCode**: Settings are located in `editors/vscode/settings.json`. Make sure to handle all platform paths (macOS, Linux, VSCodium, VSCode Insiders).
- **Vim**: Vim configurations are based on `amix/vimrc`. Customizations go to `config/my_configs.vim`.
- **Git**: Ensure the global `.gitignore` is correctly linked to the repo's `.gitignore`.

## 5. Adding New Tools
- Try to use lightweight, fast version/package managers when possible (e.g., `fnm` for Node, `uv` for Python).
- Do not add heavy dependencies unless strictly necessary.

## 6. Testing
- If possible, verify script behavior locally without permanently disrupting the user's environment, or prompt the user for confirmation.
