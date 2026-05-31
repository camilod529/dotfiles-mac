#!/usr/bin/env zsh

# Install Oh My Zsh if it isn't already installed
if [ -d ~/.oh-my-zsh ]; then
    echo "Oh My Zsh is already installed."
else
    echo "Oh My Zsh is not installed. Installing Oh My Zsh."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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

# Symlink files
if [ -f ~/.zshrc ]; then
    echo "~/.zshrc exists. Deleting old ~/.zshrc."
    rm ~/.zshrc
else
    echo "~/.zshrc does not exist. Proceeding with symlink creation."
fi
if [ -f ~/.spaceshiprc.zsh ]; then
    echo "~/.spaceshiprc.zsh exists. Deleting old ~/.spaceshiprc.zsh."
    rm ~/.spaceshiprc.zsh
else
    echo "~/.spaceshiprc.zsh does not exist. Proceeding with symlink creation."
fi
if [ -f ~/.gitconfig ]; then
    echo "~/.gitconfig exists. Deleting old ~/.gitconfig."
    rm ~/.gitconfig
else
    echo "~/.gitconfig does not exist. Proceeding with symlink creation."
fi
if [ -f ~/.tool-versions ]; then
    echo "~/.tool-versions exists. Deleting old ~/.tool-versions."
    rm ~/.tool-versions
else
    echo "~/.tool-versions does not exist. Proceeding with symlink creation."
fi

if [ -f ~/.config/topgrade.toml ]; then
    echo "~/.config/topgrade.toml exists. Deleting old ~/.config/topgrade.toml."
    rm ~/.config/topgrade.toml
else
    echo "~/.config/topgrade.toml does not exist. Proceeding with symlink creation."
fi

ln -s ~/projects/dotfiles/zsh/.zshrc  ~/.zshrc
ln -s ~/projects/dotfiles/zsh/.spaceshiprc.zsh  ~/.spaceshiprc.zsh
ln -s ~/projects/dotfiles/git/.gitconfig  ~/.gitconfig
ln -s ~/projects/dotfiles/.tool-versions ~/.tool-versions
ln -s ~/projects/dotfiles/configs/topgrade.toml ~/.config/topgrade.toml

if [ -f ~/.zshrc ]; then
    source ~/.zshrc
else
    echo "Symlink creation failed. ~/.zshrc does not exist."
    return 1
fi
