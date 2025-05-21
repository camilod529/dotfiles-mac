#!/usr/bin/env zsh

# Install asdf if it isn't already installed
if ! command -v asdf &>/dev/null; then
    echo "asdf not installed. Install the precompiled binary and re-run the script"
    return 1
else
    echo "asdf is already installed."
fi

if ! asdf plugin list | grep -q "nodejs"; then
    echo "Installing asdf nodejs plugin..."
    asdf plugin add nodejs
fi

if ! asdf plugin list | grep -q "python"; then
    echo "Installing asdf python plugin..."
    sudo apt install make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl git libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    asdf plugin add python
fi

if ! asdf plugin list | grep -q "ruby"; then
    echo "Installing asdf ruby plugin..."
    sudo apt-get install autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
    asdf plugin add ruby
fi

asdf install
