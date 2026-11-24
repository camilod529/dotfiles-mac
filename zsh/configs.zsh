# Custom ZSH configurations, aliases, etc.

# Oh My Zsh Plugins
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# brew
eval $(/opt/homebrew/bin/brew shellenv)

# asdf
export ASDF_DATA_DIR=$HOME/.asdf
export PATH="$ASDF_DATA_DIR/shims:$PATH"

# aliases
## Git
alias gc="git branch --no-merged | grep -v 'remotes/' | xargs git branch -D"

# Commands
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
if command -v go >/dev/null 2>&1; then
    export PATH=$PATH:$(go env GOPATH)/bin
fi

# zsh custom scripts
source ~/projects/dotfiles/zsh/commands/mkpr.zsh

## AWS
aws-profile() {
  if [[ -z "$1" ]]; then
    echo "Usage: aws-profile <profile-name>"
    return 1
  fi

  export AWS_PROFILE="$1"
  echo "AWS_PROFILE set to '$AWS_PROFILE'"
}

_aws_profile() {
  local profiles

  # Get AWS profiles (silence errors)
  profiles=(${(f)"$(aws configure list-profiles 2>/dev/null)"})

  _describe -t aws-profiles "AWS profiles" profiles
}

compdef _aws_profile aws-profile

## Git
# Generate a git log report for all repositories in the current directory
# Usage: git-report [period] [--from YYYY-MM-DD] [--to YYYY-MM-DD] [--author EMAIL]
#   period: day | week | month (default: month)
#   --from: start date (requires --to)
#   --to:   end date   (requires --from)
#   --author: commit author (default: each repo's git config user.email)
git-report() {
  local period=""
  local base_dir="${PWD}"
  local output_file
  local since_arg
  local until_arg=""
  local from_date=""
  local to_date=""
  local author=""

  # --- Parse arguments ---
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --from)
        from_date="$2"
        shift 2
        ;;
      --to)
        to_date="$2"
        shift 2
        ;;
      --author)
        author="$2"
        shift 2
        ;;
      day|week|month)
        period="$1"
        shift
        ;;
      *)
        echo "❌ Unknown argument: $1"
        echo "Usage: git-report [day|week|month] [--from YYYY-MM-DD --to YYYY-MM-DD] [--author EMAIL]"
        return 1
        ;;
    esac
  done

  # --- Validate flag combinations ---
  if [[ -n "$from_date" || -n "$to_date" ]]; then
    # Custom date range mode
    if [[ -z "$from_date" || -z "$to_date" ]]; then
      echo "❌ Both --from and --to are required when using custom date range."
      return 1
    fi
    if [[ -n "$period" ]]; then
      echo "❌ Cannot combine a period (day/week/month) with --from/--to flags."
      return 1
    fi
    since_arg="--since=${from_date}"
    until_arg="--until=${to_date} 23:59:59"
    output_file="report_${from_date}_to_${to_date}.txt"
  else
    # Period mode
    period="${period:-month}"
    case "$period" in
      day)
        since_arg="--since=midnight"
        output_file="daily_report_$(date +%Y-%m-%d).txt"
        ;;
      week)
        since_arg="--since='1 week ago'"
        output_file="weekly_report_$(date +%Y-%m-%d).txt"
        ;;
      month)
        since_arg="--since='$(date +%Y-%m-01)'"
        output_file="monthly_report_$(date +%m_%Y).txt"
        ;;
    esac
  fi

  rm -f "$output_file"
  echo "📁 Scanning repositories in $base_dir for period: ${from_date:+$from_date → $to_date}${period}"
  echo ""

  # Loop through all immediate subdirectories (excluding hidden ones)
  for project in */ ; do
    project="${project%/}"
    [[ ! -d "$project" ]] && continue

    local repo_path="$base_dir/$project"
    local git_path="$repo_path/.git"

    if [[ ! -e "$git_path" ]]; then
      echo "❌ Skipping $project (not a git repository)"
      continue
    fi

    if [[ -f "$git_path" ]]; then
      echo "⚠️  Skipping $project (git worktree/submodule – would duplicate commits)"
      continue
    fi

    echo "✅ Processing: $project"

    {
      echo "--- Project: $project ---"
      cd "$repo_path" || return

      local branches=("dev" "master" "develop" "main")
      local branch_used=""
      for branch in "${branches[@]}"; do
        if git show-ref --verify --quiet "refs/heads/$branch"; then
          branch_used="$branch"
          break
        fi
      done

      if [[ -n "$branch_used" ]]; then
        git log "$branch_used" \
          --author="${author:-$(git config user.email)}" \
          $since_arg \
          ${until_arg:+$until_arg} \
          --pretty=format:"%h | %ad | %s" \
          --date=format:"%Y-%m-%d %H:%M" 2>/dev/null
      else
        echo "# No dev/main/master branch found; showing commits on current HEAD" >&2
        git log HEAD \
          --author="${author:-$(git config user.email)}" \
          $since_arg \
          ${until_arg:+$until_arg} \
          --pretty=format:"%h | %ad | %s" \
          --date=format:"%Y-%m-%d %H:%M" 2>/dev/null
      fi

      cd - >/dev/null
    } >> "$output_file"
    echo "" >> "$output_file"
  done

  echo ""
  if [[ -s "$output_file" ]]; then
    echo "🚀 Report generated: $output_file"
  else
    echo "⚠️  No commits found for the given period. Empty report deleted."
    rm -f "$output_file"
  fi
}

# Zsh autocompletion
_git-report() {
  local state
  _arguments \
    '1: :->period' \
    '--from[Start date (YYYY-MM-DD)]:date' \
    '--to[End date (YYYY-MM-DD)]:date' \
    '--author[Commit author email]:email'

  case $state in
    period) _values 'period' 'day' 'week' 'month' ;;
  esac
}
compdef _git-report git-report
