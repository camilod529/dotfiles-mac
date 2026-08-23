# Set up Git Credentials

```sh
ssh-keygen -t ed25519 -C "camilod529@gmail.com" -f ~/.ssh/personal_key
```

```sh
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/personal_key
```

Copy the ssh key and add it to [Github](https://github.com/settings/keys):

```sh
tr -d '\n' < ~/.ssh/personal_key.pub | pbcopy
```

# Run Installation script

Create `projects` folder and go inside:

```sh
mkdir projects && cd projects
```

Clone dotfiles repository:

```sh
git clone git@github.com:camilod529/dotfiles-mac.git
```

Run installation script:

```sh
zsh setup.sh
```

# Set Up Work Git Identity (optional)

Any repo cloned under `~/projects/work/` automatically uses a separate git identity via `includeIf` in `git/.gitconfig`. To enable it:

```sh
cp git/.gitconfig-work.example ~/.gitconfig-work
```

Edit `~/.gitconfig-work` with your real work email, and generate a separate SSH key for it:

```sh
ssh-keygen -t ed25519 -C "you@work.com" -f ~/.ssh/work_key
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/work_key
```

`~/.gitconfig-work` is machine-local and gitignored — it's never committed to this repo.

# Set Up Logi Option+ Backup

Sometimes, the symlink process can cause problems. If that is the case, after running the instalation script, use the `Activity Monitor` app to `Quit` all ongoing `Logi Options` processes (might need to restart computer).
This is the path in MacOS where the settings are located:

```sh
~/Library/Application\ Support/LogiOptionsPlus
```

# Resources

- [asdf](https://asdf-vm.com)
- [Configure Multiple Git Accounts](https://dev.to/gitguardian/8-easy-steps-to-set-up-multiple-git-accounts-cheat-sheet-included-4i8j)
- [Example Dotfiles repo](https://github.com/CoreyMSchafer/dotfiles)
- [GitHub's SSH key fingerprints](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
- [Homebrew](https://brew.sh)
- [Multiple Github Accounts](https://gist.github.com/Jonalogy/54091c98946cfe4f8cdab2bea79430f9)
