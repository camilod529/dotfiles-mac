# Set up Git Credentials
```sh
ssh-keygen -t ed25519 -C "juan.gomez@neostella.com" -f ~/.ssh/work_key 
```
```sh
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/work_key
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
git clone git@github.com:juan-gomez-neostella/dotfiles.git
```
Run installation script:
```sh
zsh setup.sh
```

# Resources
* [Configure Multiple Git Accounts](https://dev.to/gitguardian/8-easy-steps-to-set-up-multiple-git-accounts-cheat-sheet-included-4i8j)
* [Example Dotfiles repo](https://github.com/CoreyMSchafer/dotfiles)
* [asdf](https://asdf-vm.com)
* [Homebrew](https://brew.sh)
* [GitHub's SSH key fingerprints](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
* [Multiple Github Accounts](https://gist.github.com/Jonalogy/54091c98946cfe4f8cdab2bea79430f9)
