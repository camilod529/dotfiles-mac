#!/usr/bin/env zsh

# Verify brew is now accessible
if ! command -v brew &>/dev/null; then
    echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    exit 1
fi

# Install asdf if it isn't already installed
if ! command -v asdf &>/dev/null; then
    echo "asdf not installed. Installing asdf."
    if command -v brew &>/dev/null; then
        brew install asdf
    else
        sudo apt-get install -y asdf
    fi
else
    echo "asdf is already installed."
fi

# Always ensure asdf shims are on PATH for the rest of *this* script run —
# without this, "asdf is already installed" skips the block above and
# subsequent `node`/`python` calls in this same process fail until a new
# shell sources .zshrc.
export ASDF_DATA_DIR=$HOME/.asdf
export PATH="$ASDF_DATA_DIR/shims:$PATH"

if ! asdf plugin list | grep -q "nodejs"; then
    echo "Installing asdf nodejs plugin..."
    brew install gpg gawk
    asdf plugin add nodejs
fi

if ! asdf plugin list | grep -q "python"; then
    echo "Installing asdf python plugin..."
    brew install openssl@3 readline sqlite3 xz tcl-tk@8 libb2 zstd zlib pkgconfig
    asdf plugin add python
fi

asdf install
