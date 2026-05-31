# Custom ZSH configurations, aliases, etc.

# Oh My Zsh Plugins
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# brew
eval $(/opt/homebrew/bin/brew shellenv)

# asdf
export ASDF_DATA_DIR=$HOME/.asdf
export PATH="$ASDF_DATA_DIR/shims:$PATH"

# aliases
## colorls (ls with icons)
alias lc="colorls"
## Git
alias gc="git branch --no-merged | grep -v 'remotes/' | xargs git branch -D"

# Commands
## Git
# gcp() {
#     git clone git@github.com:juan-gomez-neostella/$1.git
# }
## Brew
brewc() {
    # list of casks you want to skip
    # SKIP=("rectangle")

    brew outdated -g
    echo -n "Do you want to update? (Y/n) "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Updating..."
        brew update

        # get all outdated greedy casks into an array
        casks=()
        while IFS= read -r cask; do
            # skip empty lines
            [[ -z "$cask" ]] && continue
            
            # check if this cask should be skipped
            skip_cask=0
            for skip in "${SKIP[@]}"; do
                if [[ "$cask" == "$skip" ]]; then
                    skip_cask=1
                    break
                fi
            done
            
            # add to array if not skipped
            [[ $skip_cask -eq 0 ]] && casks+=("$cask")
        done < <(brew outdated --greedy --cask | awk '{print $1}')

        # upgrade formulae
        brew upgrade

        # upgrade filtered casks if any
        if [[ ${#casks[@]} -gt 0 ]]; then
            echo "Upgrading casks: ${casks[*]}"
            brew upgrade --cask "${casks[@]}"
        fi
    else
        echo "Skipping update."
    fi
    brew cleanup && brew doctor
}
# Fastfetch
# fastfetch

# Python
## List pip packages size
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

# Go
export PATH=$PATH:$(go env GOPATH)/bin

# zsh custom scripts
source ~/projects/dotfiles/zsh/commands/mkpr.zsh