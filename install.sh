#!/usr/bin/env zsh
# Entrypoint for macOS, Linux (personal + server), and WSL.
#
# Usage:
#   ./install.sh                # full install: symlinks + packages
#   ./install.sh --server       # symlinks + CLI-only packages, no GUI apps
#   ./install.sh --no-packages  # symlinks only, skip all package installs
#                                # (for restricted/work machines)

set -e

REPO_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
DOTFILES_PROFILE="desktop"
SKIP_PACKAGES=false

for arg in "$@"; do
    case "$arg" in
        --server) DOTFILES_PROFILE="server" ;;
        --no-packages) SKIP_PACKAGES=true ;;
    esac
done
export DOTFILES_PROFILE

case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux) OS="linux" ;;
    *)
        echo "Unsupported OS: $(uname -s). Use install.ps1 on native Windows."
        exit 1
        ;;
esac

IS_WSL=false
if [ "$OS" = "linux" ] && grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
fi

echo "==> Detected: $OS$($IS_WSL && echo ' (WSL)') / profile: $DOTFILES_PROFILE"

# ----------------------
# 1. Symlink dotfiles via GNU Stow
# ----------------------
if ! command -v stow &>/dev/null; then
    echo "==> Installing GNU Stow"
    if [ "$OS" = "macos" ]; then
        command -v brew &>/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
        brew install stow
    else
        sudo apt-get update && sudo apt-get install -y stow
    fi
fi

echo "==> Symlinking dotfiles with stow"
STOW_PACKAGES=(zsh git claude config)
stow -d "$REPO_DIR" -t "$HOME" -R "${STOW_PACKAGES[@]}"

# .tool-versions stays at the repo root (not a stow package) so asdf also
# resolves it when running commands from inside the dotfiles repo itself.
ln -sf "$REPO_DIR/.tool-versions" "$HOME/.tool-versions"

# ----------------------
# 2. Shell (Oh My Zsh, plugins, theme)
# ----------------------
if [ "$SKIP_PACKAGES" = false ]; then
    echo "==> Setting up zsh"
    source "$REPO_DIR/packages/oh-my-zsh.sh"
fi

# ----------------------
# 3. Package manager + apps
# ----------------------
if [ "$SKIP_PACKAGES" = false ]; then
    if [ "$OS" = "macos" ]; then
        source "$REPO_DIR/packages/brew.sh"
    else
        bash "$REPO_DIR/packages/apt.sh"
    fi

    echo "==> Setting up asdf + language runtimes"
    source "$REPO_DIR/asdf.sh"
fi

# ----------------------
# 4. Cross-platform git config
# ----------------------
git config --global core.autocrlf input

# ----------------------
# 5. macOS-only extras
# ----------------------
if [ "$OS" = "macos" ]; then
    xcode-select --install 2>/dev/null || true
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    echo -n "Enter a hostname for this Mac (leave blank to skip): "
    read -r new_hostname
    if [ -n "$new_hostname" ]; then
        sudo scutil --set HostName "$new_hostname"
    fi

    if [ "$SKIP_PACKAGES" = false ] && [ -f "$REPO_DIR/macos/logi/settings.db" ]; then
        echo "==> Setting up Logi Options+ config"
        LOGI_DIR=~/"Library/Application Support/LogiOptionsPlus"
        mkdir -p "$LOGI_DIR"
        [ -e "$LOGI_DIR/settings.db" ] && rm "$LOGI_DIR/settings.db"
        ln -s "$REPO_DIR/macos/logi/settings.db" "$LOGI_DIR/settings.db"
    fi

    echo "Note: macos/rectangle/RectangleConfig.json is a manual-import backup"
    echo "— import it via Rectangle > Settings > Import."
fi

echo "==> Done. Restart your terminal (or 'exec zsh') to pick up shell changes."
