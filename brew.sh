#!/usr/bin/env zsh

# Install Homebrew if it isn't already installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not installed. Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Attempt to set up Homebrew PATH automatically for this session
    if [ -x "/opt/homebrew/bin/brew" ]; then
        echo "Configuring Homebrew in PATH for Apple Silicon Mac..."
        eval $(/opt/homebrew/bin/brew shellenv)
    fi
else
    echo "Homebrew is already installed."
fi

# Verify brew is now accessible
if ! command -v brew &>/dev/null; then
    echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    exit 1
fi

# Update Homebrew and Upgrade any already-installed formulae
brew update
brew upgrade
brew cleanup

# Define an array of packages to install using Homebrew.
packages=(
    "asdf"
    "fastfetch"
    "shfmt"
    "wget"
    "curl"
    "htop"
    "tree"
    "bat"
    "gh"
    "lsd"
)

# Loop over the array to install each application.
for package in "${packages[@]}"; do
    if brew list --formula | grep -q "^$package\$"; then
        echo "$package is already installed. Skipping..."
    else
        echo "Installing $package..."
        brew install "$package"
    fi
done

# Define an array of applications to install using Homebrew Cask.
apps=(
    "bruno"
    "claude-code"
    "dbeaver-community"
    "docker"
    "rectangle"
    "spotify"
    "the-unarchiver"
    "visual-studio-code"
    "ghostty"
    "obsidian"
    "discord"
    "vlc"
    "whatsapp"
    "google-chrome"
    "firefox"
    "topgrade"
)

# Loop over the array to install each application.
for app in "${apps[@]}"; do
    if brew list --cask | grep -q "^$app\$"; then
        echo "$app is already installed. Skipping..."
    else
        echo "Installing $app..."
        brew install --cask "$app"
    fi
done

# Install Speedtest by Okkla
brew tap teamookla/speedtest
brew update
brew install speedtest --force

fonts=(
    "font-caskaydia-mono-nerd-font"
    "font-monaspace-nerd-font"
    "font-fira-code-nerd-font"
    "font-mononoki-nerd-font"
)

for font in "${fonts[@]}"; do
    if brew list | grep -q "^$font\$"; then
        echo "$font is already installed. Skipping..."
    else
        echo "Installing $font..."
        brew install "$font"
    fi
done

# Update and clean up again for safe measure
brew update
brew upgrade
brew cleanup
