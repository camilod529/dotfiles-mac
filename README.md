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
