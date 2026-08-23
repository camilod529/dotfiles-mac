#!/usr/bin/env zsh
# Installs Oh My Zsh + theme/plugins. Symlinking is handled by `stow` in
# install.sh, not here.

# Install Oh My Zsh if it isn't already installed
if [ -d ~/.oh-my-zsh ]; then
    echo "Oh My Zsh is already installed."
else
    echo "Oh My Zsh is not installed. Installing Oh My Zsh."
    # --unattended stops the installer from changing the default shell or
    # exec-ing into a new shell when it finishes — without this it replaces
    # the current process and silently kills the rest of this script,
    # which is why installs used to need to be run twice.
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Spaceship theme if it isn't already installed
if [ -d ~/.oh-my-zsh/custom/themes/spaceship-prompt ]; then
    echo "Spaceship theme is already installed."
else
    echo "Spaceship theme is not installed. Installing Spaceship theme."
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
    ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
fi

# Install plugins
if [ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    echo "zsh-autosuggestions plugin is already installed."
else
    echo "zsh-autosuggestions plugin is not installed. Installing zsh-autosuggestions plugin."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    echo "zsh-syntax-highlighting plugin is already installed."
else
    echo "zsh-syntax-highlighting plugin is not installed. Installing zsh-syntax-highlighting plugin."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

if [ -d ~/.oh-my-zsh/custom/plugins/zsh-completions ]; then
    echo "zsh-completions plugin is already installed."
else
    echo "zsh-completions plugin is not installed. Installing zsh-completions plugin."
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
fi
