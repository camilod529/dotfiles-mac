# Native Windows package list (winget). Called by install.ps1.
# NOTE: winget package IDs occasionally change — verify with
# `winget search <name>` if an id below 404s.

# Core CLI tools. `tree` and `curl` ship with modern Windows already.
$corePackages = @(
    "Fastfetch-cli.Fastfetch",
    "GNU.Wget2",
    "junegunn.htop",
    "GitHub.cli",
    "sharkdp.bat",
    "lsd-rs.lsd",
    "mvdan.shfmt"
)

foreach ($pkg in $corePackages) {
    winget install --id $pkg --silent --accept-source-agreements --accept-package-agreements
}

# Claude Code CLI (npm, not winget) — needs Node on PATH (install via asdf
# or nvm-windows first).
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    npm install -g @anthropic-ai/claude-code
}

if ($env:DOTFILES_PROFILE -eq "server") {
    Write-Host "Server profile: skipping GUI apps."
    exit 0
}

$desktopPackages = @(
    "Docker.DockerDesktop",
    "Microsoft.VisualStudioCode",
    "Obsidian.Obsidian",
    "Discord.Discord",
    "VideoLAN.VLC",
    "Google.Chrome",
    "Mozilla.Firefox",
    "Spotify.Spotify",
    "Bruno.Bruno",
    "dbeaver.dbeaver",
    "WhatsApp.WhatsApp",
    "Logitech.OptionsPlus"
)

foreach ($pkg in $desktopPackages) {
    winget install --id $pkg --silent --accept-source-agreements --accept-package-agreements
}
