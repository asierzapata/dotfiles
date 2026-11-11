#!/bin/bash
#
# Share global agent instructions and skills with every coding agent.
#
# agents/AGENTS.md and agents/skills/ are the single source. This links them
# into each installed agent's global folders. It only creates or replaces
# symlinks. A real file or folder at a target is left alone with a warning,
# because it may hold settings or skills that live outside the dotfiles.

DOTFILES_AGENTS="$HOME/.dotfiles/agents"
INSTRUCTIONS="$DOTFILES_AGENTS/AGENTS.md"
SKILLS="$DOTFILES_AGENTS/skills"
XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

# link SOURCE TARGET
link() {
  local source="$1" target="$2"
  if [ -L "$target" ]; then
    [ "$(readlink "$target")" = "$source" ] && return 0
    rm "$target"
  elif [ -e "$target" ]; then
    echo "  Skipped $target: a real file is there. Move it away to link $source."
    return 0
  fi
  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  echo "  Linked $target"
}

# link_skills LABEL DIR
link_skills() {
  local label="$1" dir="$2"
  mkdir -p "$dir"
  # Drop links to skills that were renamed or removed from the dotfiles,
  # including links left from when they lived under claude/skills.
  for entry in "$dir"/*; do
    if [ -L "$entry" ] && [ ! -e "$entry" ]; then
      case "$(readlink "$entry")" in
        "$HOME/.dotfiles/"*) rm "$entry" && echo "  Removed stale skill link $entry" ;;
      esac
    fi
  done
  for skill in "$SKILLS"/*/; do
    skill="${skill%/}"
    link "$skill" "$dir/$(basename "$skill")"
  done
  echo "  $label skills: $dir"
}

# Claude Code reads its own folder. claude/CLAUDE.md imports AGENTS.md and is
# linked by claude/install.sh.
link_skills "Claude Code" "$HOME/.claude/skills"

# The cross-agent user folder from the Agent Skills standard. Codex and the
# Devin CLI both read it.
link_skills "Codex and Devin" "$HOME/.agents/skills"

if [ -d "$HOME/.codex" ] || command -v codex >/dev/null 2>&1; then
  link "$INSTRUCTIONS" "$HOME/.codex/AGENTS.md"
fi

if [ -d "$XDG_CONFIG/devin" ] || command -v devin >/dev/null 2>&1; then
  link "$INSTRUCTIONS" "$XDG_CONFIG/devin/AGENTS.md"
fi

# Antigravity has moved its global skills folder between releases. Use the
# current one, plus the CLI's own folder when the CLI is installed.
if [ -d "$HOME/.gemini" ]; then
  link "$INSTRUCTIONS" "$HOME/.gemini/GEMINI.md"
  link_skills "Antigravity" "$HOME/.gemini/config/skills"
  [ -d "$HOME/.gemini/antigravity-cli" ] && link_skills "Antigravity CLI" "$HOME/.gemini/antigravity-cli/skills"
fi

exit 0
