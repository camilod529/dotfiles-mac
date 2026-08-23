# Set up Git Credentials

Every machine generates and keeps its own SSH key — never copy a private key between machines.

```sh
ssh-keygen -t ed25519 -C "camilod529@gmail.com" -f ~/.ssh/personal_key
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/personal_key
```

Copy the SSH key and add it to [GitHub](https://github.com/settings/keys):

```sh
# macOS
tr -d '\n' < ~/.ssh/personal_key.pub | pbcopy
# Linux (needs xclip or wl-clipboard)
tr -d '\n' < ~/.ssh/personal_key.pub | xclip -selection clipboard
# Windows (PowerShell)
Get-Content $HOME\.ssh\personal_key.pub | Set-Clipboard
```

# Run the installer

Clone the repo (same on every OS):

```sh
mkdir -p ~/projects && cd ~/projects
git clone git@github.com:camilod529/dotfiles-mac.git dotfiles
cd dotfiles
```

**macOS, Linux (desktop or server), or WSL:**

```sh
zsh install.sh                # full install
zsh install.sh --server       # CLI-only, no GUI apps (for headless Linux servers)
zsh install.sh --no-packages  # symlinks only, skip all installs (for locked-down/work machines)
```

**Native Windows (PowerShell, no WSL):** creating symlinks needs Developer Mode on
(`Settings > Privacy & Security > For developers > Developer Mode`), or an elevated shell.

```powershell
.\install.ps1                 # full install
.\install.ps1 -Server         # CLI-only, no GUI apps
.\install.ps1 -NoPackages     # symlinks only, skip all installs
```

Both installers are idempotent — safe to re-run any time.

## How this repo is organized

Dotfiles are managed with [GNU Stow](https://www.gnu.org/software/stow/): each
top-level folder (`zsh/`, `git/`, `claude/`, `config/`) is a "package" whose
internal path mirrors `$HOME`, e.g. `zsh/.zshrc` → `~/.zshrc`. `install.sh`
runs `stow` to symlink them. This means the files in this repo _are_ your
live config — edit `~/.zshrc` directly and the repo is already up to date
(it's a symlink, not a copy), same as it's always worked here.

`macos/` holds macOS-only extras (Rectangle, Logi Options+) that aren't
generically stowed — `install.sh` handles them with a bit of extra logic on
Darwin only. `packages/` holds the per-OS app-install scripts
(`brew.sh`, `apt.sh`, `winget.ps1`).

# Set Up Work Git Identity (optional)

Any repo cloned under `~/projects/work/` automatically uses a separate git identity via `includeIf` in `git/.gitconfig`. To enable it:

```sh
cp .gitconfig-work.example ~/.gitconfig-work
```

Edit `~/.gitconfig-work` with your real work email, and generate a separate SSH key for it:

```sh
ssh-keygen -t ed25519 -C "you@work.com" -f ~/.ssh/work_key
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/work_key
```

`~/.gitconfig-work` is machine-local and gitignored — it's never committed to this repo.

# Set Up Logi Options+ Backup (macOS)

Sometimes the symlink process can cause problems. If that happens, after running the installer, use `Activity Monitor` to quit all `Logi Options` processes (a restart may be needed). Settings live at:

```sh
~/Library/Application\ Support/LogiOptionsPlus
```

# Linux notes

`packages/apt.sh` targets Debian/Ubuntu-based distros. Package names/availability
vary by distro and release — some GUI apps (Bruno, DBeaver, Ghostty, WhatsApp)
have no reliable stock apt package and need a flatpak/snap/direct download
instead. Expect to patch this file after the first run on a new distro.

# Resources

- [asdf](https://asdf-vm.com)
- [GNU Stow](https://www.gnu.org/software/stow/)
- [Configure Multiple Git Accounts](https://dev.to/gitguardian/8-easy-steps-to-set-up-multiple-git-accounts-cheat-sheet-included-4i8j)
- [GitHub's SSH key fingerprints](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
- [Homebrew](https://brew.sh)
- [topgrade](https://github.com/topgrade-rs/topgrade)
