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
##Brew
# brewc() {
#     brew outdated -g
#     echo -n "Do you want to update? (Y/n) "
#     read -r response
#     if [[ "$response" =~ ^[Yy]$ ]]; then
#         echo "Updating..."
#         brew update && brew upgrade --greedy
#     else
#         echo "Skipping update."
#     fi
#     brew cleanup && brew doctor
# }
##APT
aptc() {
    echo "Updating..."
    sudo apt update && sudo apt upgrade
}
