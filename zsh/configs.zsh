# Custom ZSH configurations, aliases, etc.

#Oh My Zsh Plugins
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

#asdf
export PATH="$HOME/.asdf/bin:$PATH"
export ASDF_DATA_DIR=$HOME/.asdf
export PATH="$ASDF_DATA_DIR/shims:$PATH"

#aliases
##colorls (ls with icons)
alias lc="colorls"
##Git
alias gc="git branch --no-merged | grep -v 'remotes/' | xargs git branch -D"

#Commands
##Git
gcp() {
    git clone git@github.com:juan-gomez-neostella/$1.git
}
##APT
aptc() {
    echo "Updating..."
    sudo apt update && sudo apt upgrade
}

#Fastfetch
# fastfetch

# Python
# List pip packages size
pipsize() {
    LANG=C pip list |
        tail -n +3 |
        awk '{print $1}' |
        xargs pip show |
        grep -E 'Location:|Name:' |
        cut -d ' ' -f 2 |
        paste -d ' ' - - |
        awk '{print $2 "/" tolower($1)}' |
        xargs du -sh 2>/dev/null |
        sort -hr
}

#Neostella
alias vscode="code --remote wsl+ubuntu \"\$(pwd)\""

alias vinebotsdev="export AWS_PROFILE=vinebotsdev"
alias vinebotsqa="export AWS_PROFILE=vinebotsqa"
alias vineportaldev="export AWS_PROFILE=vineportaldev"
alias vineportalqa="export AWS_PROFILE=vineportalqa"
