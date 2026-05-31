# ─── Helper: fetch repo labels and prompt user to pick one or more ───────────
_mkpr_prompt_labels() {
  local repo_slug="$1"

  local available_labels
  available_labels="$(gh label list --repo "$repo_slug" --limit 100 --json name --jq '.[].name' 2>/dev/null)"

  if [[ -z "$available_labels" ]]; then
    echo "⚠️  Could not fetch labels for $repo_slug — skipping" >&2
    return
  fi

  echo "🏷️  Select label(s):" >&2

  local selected=""

  if command -v fzf >/dev/null 2>&1; then
    selected="$(printf '%s\n' "${(f)available_labels}" | fzf \
      --multi \
      --prompt='  Label > ' \
      --height=12 --border --ansi)"
    # fzf --multi returns newline-separated; convert to comma-separated
    selected="$(echo "$selected" | tr '\n' ',' | sed 's/,$//')"
  else
    local -a label_arr=("${(f)available_labels}")
    local count="${#label_arr[@]}"
    local i=1
    for l in "${label_arr[@]}"; do
      echo "  $i) $l" >&2
      ((i++))
    done
    printf "  Choice [1-$count, comma-separated for multiple]: " >&2
    local choice
    read choice
    local -a choices=("${(@s:,:)choice}")
    local -a picked=()
    for c in "${choices[@]}"; do
      c="${c// /}"
      if [[ "$c" =~ ^[0-9]+$ ]] && (( c >= 1 && c <= count )); then
        picked+=("${label_arr[$c]}")  # zsh arrays are 1-indexed
      fi
    done
    local IFS=','
    selected="${picked[*]}"
  fi

  [[ -n "$selected" ]] && echo "🏷️  Label(s): $selected" >&2
  echo "$selected"
}


# ─── Helper: given a list of PRs as JSON, let the user select one ─────────────
# Prints the 0-based index of the selected PR to stdout, or -1 if aborted.
_mkpr_select_pr() {
  local pr_json="$1"
  local pr_count="$2"

  # Single PR: auto-select without prompting
  if [[ "$pr_count" -eq 1 ]]; then
    echo "0"
    return
  fi

  echo "⚠️  Multiple open PRs found on this branch. Please select one:" >&2

  if command -v fzf >/dev/null 2>&1; then
    local fzf_lines
    fzf_lines="$(printf '%s\n' "$pr_json" | jq -r '.[] | "\(.title)  →  \(.url)"')"
    local selected_line
    selected_line="$(echo "$fzf_lines" | fzf --prompt='  PR > ' --height=10 --border --ansi)"
    if [[ -z "$selected_line" ]]; then
      echo "-1"
      return
    fi
    local idx=0
    while IFS= read -r line; do
      if [[ "$line" = "$selected_line" ]]; then
        echo "$idx"
        return
      fi
      ((idx++))
    done <<< "$fzf_lines"
    echo "-1"
  else
    local i=0
    while IFS= read -r line; do
      echo "  $((i+1))) $line" >&2
      ((i++))
    done < <(printf '%s\n' "$pr_json" | jq -r '.[] | "\(.title)  →  \(.url)"')
    printf "  Choice [1-$pr_count]: " >&2
    local choice
    read choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= pr_count )); then
      echo "$((choice - 1))"
    else
      echo "⚠️  Invalid choice — skipping" >&2
      echo "-1"
    fi
  fi
}


# ─── Main ─────────────────────────────────────────────────────────────────────
mkpr() {
  # ── Validate environment ────────────────────────────────────────────────────
  local current_branch
  current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || {
    echo "❌ Not a git repository"
    return 1
  }

  local repo_slug
  repo_slug="$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null)"
  if [[ -z "$repo_slug" ]]; then
    echo "❌ Could not detect GitHub repository (are you authenticated with gh?)"
    return 1
  fi

  # ── Detect base branch and strip feature prefix ─────────────────────────────
  local base_branch branch_base
  case "$current_branch" in
    *-dev)
      base_branch="dev"
      branch_base="${current_branch%-dev}"
      ;;
    *-qa)
      base_branch="qa"
      branch_base="${current_branch%-qa}"
      ;;
    *-staging)
      base_branch="staging"
      branch_base="${current_branch%-staging}"
      ;;
    *)
      echo "❌ Branch '$current_branch' must end with '-dev', '-qa', or '-staging'"
      return 1
      ;;
  esac

  # ── Detect Jira ticket ──────────────────────────────────────────────────────
  local ticket
  ticket="$(echo "$current_branch" | grep -oiE '[a-z]+-[0-9]+' | head -1 | tr '[:lower:]' '[:upper:]')"

  if [[ -z "$ticket" ]]; then
    printf "🎫  Ticket number (e.g. TEJOR-892): "
    read ticket
    ticket="$(echo "$ticket" | tr '[:lower:]' '[:upper:]')"
  else
    echo "🎫  Detected ticket: $ticket"
  fi

  # ── Determine source branches to copy from (priority order) ─────────────────
  # -dev  : no sources (always prompts)
  # -qa   : tries -dev
  # -staging: tries -qa first, then -dev as fallback
  local -a source_branches=()
  case "$base_branch" in
    qa)      source_branches=("${branch_base}-dev") ;;
    staging) source_branches=("${branch_base}-qa" "${branch_base}-dev") ;;
  esac

  # ── Search source branches for a PR to copy from ────────────────────────────
  local found_pr_body="" found_pr_title="" found_pr_labels=""

  for src_branch in "${source_branches[@]}"; do
    echo "🔍 Looking for PRs on branch '$src_branch'..."

    # Fetch open + merged PRs in one call; open ones sorted first
    local pr_json
    pr_json="$(gh pr list \
      --repo "$repo_slug" \
      --head "$src_branch" \
      --state all \
      --json number,title,url,body,labels,state \
      2>/dev/null \
      | jq '[.[] | select(.state == "OPEN" or .state == "MERGED")] | sort_by(.state != "OPEN")')"

    local pr_count
    pr_count="$(printf '%s\n' "$pr_json" | jq 'length' 2>/dev/null || echo 0)"

    if [[ "$pr_count" -eq 0 ]]; then
      echo "  No PRs found on '$src_branch'"
      continue
    fi

    local selected_idx
    selected_idx="$(_mkpr_select_pr "$pr_json" "$pr_count")"

    if (( selected_idx < 0 )); then
      echo "  Skipped '$src_branch'"
      continue
    fi

    found_pr_body="$(printf '%s\n' "$pr_json"   | jq -r ".[$selected_idx].body  // \"\"")"
    found_pr_title="$(printf '%s\n' "$pr_json"  | jq -r ".[$selected_idx].title // \"\"")"
    found_pr_labels="$(printf '%s\n' "$pr_json" | jq -r ".[$selected_idx].labels[].name" 2>/dev/null \
      | tr '\n' ',' | sed 's/,$//')"

    echo "📋 Copying from PR: $found_pr_title"
    break
  done

  # ── Labels ──────────────────────────────────────────────────────────────────
  # tejo-frontend: copy from source PR if available, otherwise prompt
  # all other repos: always prompt
  local label=""

  if [[ "$repo_slug" = "Neostella/tejo-frontend" && -n "$found_pr_labels" ]]; then
    echo "🏷️  Copying labels from source PR: $found_pr_labels"
    label="$found_pr_labels"
  else
    label="$(_mkpr_prompt_labels "$repo_slug")"
  fi

  # ── Prompt for title when no source PR was found ─────────────────────────────
  local title_input=""

  if [[ -z "$found_pr_body" ]]; then
    printf "📝 PR title: "
    read title_input
    if [[ -z "$title_input" ]]; then
      echo "❌ Title is required"
      return 1
    fi
  fi

  # ── Build final title ────────────────────────────────────────────────────────
  local title
  if [[ -n "$found_pr_title" ]]; then
    title="$found_pr_title"
  elif [[ -n "$ticket" ]]; then
    title="$title_input - $ticket"
  else
    title="$title_input"
  fi

  # ── Body: fall back to PR template if nothing was copied ─────────────────────
  local body="$found_pr_body"

  if [[ -z "$body" ]]; then
    local repo_root
    repo_root="$(git rev-parse --show-toplevel)"
    local template_path="$repo_root/.github/pull_request_template.md"

    if [[ -f "$template_path" ]]; then
      body="$(cat "$template_path")"
      [[ -n "$ticket" ]] && body="${body//<ticket_number>/$ticket}"
      body="${body//Representative Title/$title_input}"
    fi
  fi

  # ── Reviewers ────────────────────────────────────────────────────────────────
  local reviewers=""
  case "$repo_slug" in
    Neostella/tejo-backend|\
    Neostella/tejo-automation-module|\
    Neostella/tejo-automation-runner)
      reviewers="juan-gomez-neostella,achavane-neostella,david-estrada-neostella"
      ;;
    Neostella/tejo-frontend)
      reviewers="jperez-neostella,asarmiento-neostella,svelasquez-neostella"
      ;;
    *)
      echo "⚠️  No reviewer mapping found for $repo_slug (creating PR without reviewers)"
      ;;
  esac

  local -a reviewer_args=()
  [[ -n "$reviewers" ]] && reviewer_args=(--reviewer "$reviewers")

  # ── Build --label args (handle comma-separated multi-label string) ────────────
  local -a label_args=()
  if [[ -n "$label" ]]; then
    local -a label_list=("${(@s:,:)label}")
    for l in "${label_list[@]}"; do
      l="${l## }"
      l="${l%% }"
      [[ -n "$l" ]] && label_args+=(--label "$l")
    done
  fi

  # ── Create PR ────────────────────────────────────────────────────────────────
  echo "🚀 Creating PR: $current_branch → $base_branch ($repo_slug)"

  local url
  url="$(gh pr create \
    --repo "$repo_slug" \
    --base "$base_branch" \
    --head "$current_branch" \
    --title "$title" \
    --body "$body" \
    --assignee "@me" \
    "${reviewer_args[@]}" \
    "${label_args[@]}")" || return 1

  echo "✅ PR created: $url"
  command -v open >/dev/null 2>&1 && open "$url"
}