export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="spaceship"

plugins=(zsh-autosuggestions zsh-syntax-highlighting zsh-completions macos git)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

source ~/projects/dotfiles/zsh/configs.zsh


# ----------------------
# Aliases
# ----------------------

## lsd (modern ls replacement)
alias l="lsd -l --blocks=permission,name"
alias ls="lsd"
alias la="lsd -la --blocks=permission,name"
alias ll="lsd -la"
alias lt="lsd -l --blocks=permission,date,name"
alias lta="lsd -la --blocks=permission,date,name"
alias lw="lsd -l --blocks=permission,size,name"
alias lwa="lsd -la --blocks=permission,size,name"

## bat (better cat)
alias cat="bat"

## Git shortcuts
alias gaa="git add ."
alias gss="git status -s"
alias gs="git status"
alias gpl="git pull"
alias gpsh="git push"
alias gstg="git checkout staging"

# ----------------------
# Useful tools
# ----------------------
alias fetch="fastfetch"
alias top="htop"

# ----------------------
# Exports
# ----------------------
export EDITOR="code"
export PAGER="bat"
