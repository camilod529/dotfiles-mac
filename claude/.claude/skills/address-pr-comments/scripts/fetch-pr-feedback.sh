#!/usr/bin/env bash
# Trae todo el feedback de una PR: threads en línea (con estado resuelto/obsoleto),
# reviews con cuerpo y comentarios generales. Uso: fetch-pr-feedback.sh [pr-number]
set -euo pipefail

PR="${1:-}"
if [[ -z "$PR" ]]; then
  # Sin número: toma la PR asociada a la rama actual (falla si no hay)
  PR="$(gh pr view --json number -q .number)"
fi

echo "## PR #$PR"
gh pr view "$PR" --json title,url,headRefName,baseRefName,state \
  -q '"Título: \(.title)\nURL: \(.url)\nRama PR: \(.headRefName) -> \(.baseRefName)\nEstado: \(.state)"'
echo "Rama local: $(git branch --show-current)"
echo "Working tree:"
git status --short || true

echo
echo "## Threads en línea"
# GraphQL porque REST no expone isResolved / isOutdated
gh api graphql -F owner='{owner}' -F name='{repo}' -F pr="$PR" -f query='
query($owner: String!, $name: String!, $pr: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          isOutdated
          path
          line
          originalLine
          comments(first: 50) {
            nodes { author { login } body url }
          }
        }
      }
    }
  }
}' --jq '.data.repository.pullRequest.reviewThreads.nodes'

echo
echo "## Reviews (resumen de approve / request changes)"
gh pr view "$PR" --json reviews \
  --jq '[.reviews[] | select(.body != "") | {author: .author.login, state, body}]'

echo
echo "## Comentarios generales"
gh pr view "$PR" --json comments \
  --jq '[.comments[] | {author: .author.login, body, url}]'
