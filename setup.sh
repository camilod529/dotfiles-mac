#!/usr/bin/env zsh

# Install Xcode Command Line Tools
xcode-select --install

echo "Complete the installation of Xcode Command Line Tools before proceeding."
echo "Press enter to continue..."
read

# Enable key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Run other setup scripts
source brew.sh
source asdf.sh
source zsh.sh

# Set up hostname
sudo scutil --set HostName pampa

# Set up fastfetch
mkdir -p ~/.config/fastfetch
ln -s ~/projects/dotfiles/configs/fastfetch/config.jsonc ~/.config/fastfetch/config.jsonc

# Set up Colorls (lc)
if which gem >/dev/null 2>&1; then
    gem install colorls
else
    echo "Gem doesn't seem to be configure in your PATH. Check your asdf configs."
    exit 1
fi

# Set up Logi Options+ settings file
if [ -f ~/Library/Application\ Support/LogiOptionsPlus/settings.db ]; then
    echo "settings.db exists. Deleting old settings.db"
    rm ~/Library/Application\ Support/LogiOptionsPlus/settings.db
else
    echo "settings.db does not exist. Proceeding with symlink creation."
    mkdir -p ~/Library/Application\ Support/LogiOptionsPlus
fi
ln -s ~/projects/dotfiles/configs/logi/settings.db ~/Library/Application\ Support/LogiOptionsPlus/settings.db
