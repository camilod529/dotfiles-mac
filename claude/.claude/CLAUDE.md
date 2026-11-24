# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is the global (user-level) CLAUDE.md — it applies across all of Camilo's projects and sessions, not just one repo.

## Dotfiles

Camilo's dotfiles live at `~/projects/dotfiles`. `~/projects/dotfiles/git/.gitconfig` is symlinked to `~/.gitconfig` and is live in every shell — its aliases are already available as plain `git <alias>` commands, no extra setup needed. Prefer these over writing out the equivalent raw git commands when they fit what's being asked:

- `git lg` — `log --oneline --graph --decorate --all`
- `git last` — `log -1 HEAD`
- `git undo` — `reset --soft HEAD^` (safe: keeps the undone commit's changes staged)
- `git pushme` — `push -u origin <current-branch>`
- `git fpush <branch>` / `git fpushme` — force-push (with lease semantics not implied — these are plain `--force`); treat like any other force-push and confirm before running, the alias doesn't change the risk.
- Environment-branch workflow: several aliases follow a `<branch>-<env>` naming convention (env ∈ `qa`, `dev`, `prod`, `staging`):
  - `git coqa` / `git codev` / `git costg` — checkout (creating if needed) `<current-branch>-qa` / `-dev` / `-staging`
  - `git reqa` / `git redev` / `git reprod` — delete and recreate `<current-branch>-<env>` fresh off current HEAD
  - `git gobase` — switch back to the base branch by stripping a trailing `-qa`/`-dev`/`-prod`/`-staging` suffix off the current branch name
  - `git mergebase` — merge the base branch (same suffix-stripping logic) into the current env branch
  - `git stg` / `git qa` / `git dev` / `git prod` — hard-reset local `staging`/`qa`/`dev`/`prod` to match `origin` (deletes and recreates the local branch, then pulls)

Check `~/projects/dotfiles/git/.gitconfig` directly if an alias's exact behavior matters for a decision, rather than relying on this summary — it can drift.

## Working preferences

These apply in every project unless that project's own instructions say otherwise.

### Git

- Never run `git commit` or `git push` unless I've explicitly asked for that specific change — even when a default workflow (background jobs, PR automation) would do it on its own. Finish the work, run the checks, leave the changes in the working tree and tell me it's ready.
- Never delete local branches (`git branch -d/-D`), not even fully merged ones or when removing their worktree — and don't offer to. Removing a worktree removes only the worktree.
- Only use a worktree when the current branch is dirty. If `git status` is clean, work in place.

### Checks

- Run lint, format, test and type checks through the project's own scripts with its package manager (`yarn <script>`, `npm run <script>`, …), never `npx` or a tool's binary directly. Read the scripts from the `package.json` of the checkout being worked on first: branches and worktrees can differ.
- TypeScript: when the root `tsconfig.json` is a solution file (`"files": []` + `references`), `tsc -p .` checks zero files and always passes. Use `tsc -b --noEmit` (or the project's build script). `tsc -b` is incremental: a second run in under a second is the cache, so add `--force` when the result has to be trusted.

### Code

- Keep comments lean: at most a one-line comment where the code isn't obvious; no multi-paragraph docblocks.

### Multi-repo workspaces

- When sibling repos are opened only so you can follow a contract across services, they are read-only: read them freely, but edit them (or run anything that writes there, including through scripts) only when I ask for that change.
