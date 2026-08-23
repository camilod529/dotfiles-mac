#!/usr/bin/env bash
# Linux (Debian/Ubuntu-based) package list. Sourced by install.sh on Linux.
#
# NOTE: package names/availability are best-effort — apt package names,
# especially for GUI apps, vary by distro/release and some of these ship as
# snaps/flatpaks instead. Verify and adjust after the first real run on a
# given box (see README's "Linux" section).
#
# DOTFILES_PROFILE is set by install.sh: "server" (CLI-only) or "desktop".

set -e

sudo apt-get update

core_packages=(
    asdf
    fastfetch
    shfmt
    wget
    curl
    htop
    tree
    bat
    gh
    lsd
    speedtest-cli
)

for package in "${core_packages[@]}"; do
    if dpkg -s "$package" &>/dev/null; then
        echo "$package is already installed. Skipping..."
    else
        echo "Installing $package..."
        sudo apt-get install -y "$package" || echo "WARNING: $package failed to install via apt — check the package name for your distro."
    fi
done

# Claude Code CLI (npm, not an apt package) — needs asdf's node on PATH.
if ! command -v claude &>/dev/null; then
    npm install -g @anthropic-ai/claude-code
fi

if [ "$DOTFILES_PROFILE" = "server" ]; then
    echo "Server profile: skipping GUI apps."
    exit 0
fi

desktop_packages=(
    docker.io
    code
    obsidian
    discord
    vlc
    google-chrome-stable
    firefox
    spotify-client
)

for package in "${desktop_packages[@]}"; do
    if dpkg -s "$package" &>/dev/null; then
        echo "$package is already installed. Skipping..."
    else
        echo "Installing $package..."
        sudo apt-get install -y "$package" || echo "WARNING: $package not found via apt — likely needs a PPA/flatpak/snap on this distro (e.g. VS Code needs Microsoft's apt repo, Chrome needs Google's, Obsidian/Discord/Spotify are often better as flatpak/snap)."
    fi
done

# bruno, dbeaver-community, whatsapp, ghostty: no reliable stock apt package
# across distros — install via flatpak/snap/direct download as available on
# your distro.
