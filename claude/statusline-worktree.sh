#!/bin/bash
# Claude Code status line: which worktree and Rex session this is, then ccusage.
#
#   ⎇ search-ranking  master__search-ranking-mvp ●3 · rex:search-ranking
#   🤖 Opus | 💰 ...
#
# Worktrees under ~/Documents/Projects/worktrees/<repo>/<slug> are the standard
# ones (created by the Rex worktree_new action or `wt switch -c`). Anything else
# is tagged with where it came from so it stands out.

input=$(cat)

RESET=$'\033[0m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
RED=$'\033[31m'
YELLOW=$'\033[33m'

WORKTREE_ROOT="$HOME/Documents/Projects/worktrees"

# Stable colour per worktree name, from a palette that reads on dark and light.
PALETTE=(33 39 43 71 107 135 141 167 173 179 209 214)
color_for() {
  local sum
  sum=$(printf '%s' "$1" | cksum | cut -d' ' -f1)
  printf '\033[1;38;5;%sm' "${PALETTE[$((sum % ${#PALETTE[@]}))]}"
}

dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$dir" ] && dir=$PWD

location=""
if top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null); then
  branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null ||
    git -C "$dir" rev-parse --short HEAD)
  changes=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  common=$(cd "$dir" && cd "$(git rev-parse --git-common-dir)" && pwd -P)
  name=$(basename "$top")
  tag=""
  standard=false

  case "$top" in
    "$(dirname "$common")")
      name="MAIN"
      tag="${RED}${BOLD}main checkout${RESET}"
      ;;
    "$WORKTREE_ROOT"/*/*/*)
      tag="${YELLOW}zed${RESET}"
      name="$(basename "$(dirname "$top")")/$name"
      ;;
    "$WORKTREE_ROOT"/*/*)
      standard=true
      ;;
    */.claude/worktrees/*)
      tag="${YELLOW}claude worktree${RESET}"
      ;;
    /private/tmp/* | /tmp/*)
      tag="${YELLOW}scratchpad${RESET}"
      ;;
    *)
      tag="${YELLOW}legacy path${RESET}"
      ;;
  esac

  if [ "$name" = "MAIN" ]; then
    location="${RED}${BOLD}⎇ MAIN${RESET}"
  else
    location="$(color_for "$name")⎇ ${name}${RESET}"
  fi
  location+="  ${DIM}${branch}${RESET}"
  [ "$changes" -gt 0 ] && location+=" ${YELLOW}●${changes}${RESET}"
  [ -n "$tag" ] && location+=" ${DIM}(${RESET}${tag}${DIM})${RESET}"
fi

if [ -n "$REX_SESSION" ]; then
  label=$(rex session inspect "$REX_SESSION" --json 2>/dev/null | jq -r '.label // empty')
  if [ -n "$label" ]; then
    location+=" ${DIM}·${RESET} ${DIM}rex:${RESET}${label}"
    # A standard worktree's session is named after it; anything else means the
    # session was renamed or Claude is running in another worktree's session.
    if $standard && [ "$label" != "$name" ]; then
      location+=" ${RED}≠ worktree${RESET}"
    fi
  fi
fi

[ -n "$location" ] && printf '%s\n' "$location"
printf '%s' "$input" | "$HOME/.bun/bin/ccusage" statusline
