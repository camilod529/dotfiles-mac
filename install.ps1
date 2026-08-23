# Entrypoint for native Windows (PowerShell), no WSL.
#
# Usage:
#   .\install.ps1                # full install: symlinks + packages
#   .\install.ps1 -Server        # symlinks + CLI-only packages, no GUI apps
#   .\install.ps1 -NoPackages    # symlinks only, skip all package installs
#                                 # (for restricted/work machines)
#
# Creating symlinks on Windows without admin rights requires Developer Mode:
# Settings > Privacy & Security > For developers > Developer Mode.

param(
    [switch]$Server,
    [switch]$NoPackages
)

$ErrorActionPreference = "Stop"
$RepoDir = $PSScriptRoot
$env:DOTFILES_PROFILE = if ($Server) { "server" } else { "desktop" }

function Test-DeveloperMode {
    $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    $val = (Get-ItemProperty -Path $key -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
    return $val -eq 1
}

if (-not (Test-DeveloperMode) -and -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Developer Mode is off and this shell isn't elevated — creating symlinks will fail."
    Write-Warning "Enable it via Settings > Privacy & Security > For developers > Developer Mode, then re-run."
    exit 1
}

# ----------------------
# 1. Symlink dotfiles
# ----------------------
function New-DotfileSymlink($SourceRelative, $TargetRelative) {
    $source = Join-Path $RepoDir $SourceRelative
    $target = Join-Path $HOME $TargetRelative
    $targetParent = Split-Path $target -Parent
    if (-not (Test-Path $targetParent)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }
    if (Test-Path $target) {
        $existing = Get-Item $target -Force
        if ($existing.LinkType -eq "SymbolicLink") {
            Remove-Item $target -Force
        } else {
            Write-Warning "Skipping $target — a real file already exists there. Remove/back it up manually first."
            return
        }
    }
    New-Item -ItemType SymbolicLink -Path $target -Value $source | Out-Null
    Write-Host "Linked $target -> $source"
}

Write-Host "==> Symlinking dotfiles"
New-DotfileSymlink "zsh\.zshrc" ".zshrc"                 # only meaningful if you also use zsh on Windows (e.g. via MSYS2)
New-DotfileSymlink "zsh\.spaceshiprc.zsh" ".spaceshiprc.zsh"
New-DotfileSymlink "git\.gitconfig" ".gitconfig"
New-DotfileSymlink ".tool-versions" ".tool-versions"
New-DotfileSymlink "config\.config\topgrade.toml" ".config\topgrade.toml"
New-DotfileSymlink "config\.config\fastfetch\config.jsonc" ".config\fastfetch\config.jsonc"
New-DotfileSymlink "claude\.claude\settings.json" ".claude\settings.json"
New-DotfileSymlink "claude\.claude\CLAUDE.md" ".claude\CLAUDE.md"

# ----------------------
# 2. Cross-platform git config
# ----------------------
git config --global core.autocrlf true

# ----------------------
# 3. Packages (winget)
# ----------------------
if (-not $NoPackages) {
    Write-Host "==> Installing packages via winget"
    & (Join-Path $RepoDir "packages\winget.ps1")
} else {
    Write-Host "==> Skipping package installs (-NoPackages)"
}

Write-Host "==> Done. Open a new terminal to pick up PATH/profile changes."
