#!/bin/bash
#
# Claude Code configuration setup
# Symlinks the statusline script and provides a template for settings

DOTFILES_CLAUDE="$HOME/.dotfiles/claude"
CLAUDE_DIR="$HOME/.claude"

# Create ~/.claude directory if it doesn't exist
mkdir -p "$CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/commands"

# Symlink the statusline script
# Remove existing file/symlink first to ensure clean state
if [ -e "$CLAUDE_DIR/statusline.sh" ] || [ -L "$CLAUDE_DIR/statusline.sh" ]; then
  rm "$CLAUDE_DIR/statusline.sh"
fi
ln -s "$DOTFILES_CLAUDE/statusline.sh" "$CLAUDE_DIR/statusline.sh"
chmod +x "$DOTFILES_CLAUDE/statusline.sh"

echo "  Linked statusline.sh"

# Symlink command files
if [ -d "$DOTFILES_CLAUDE/commands" ]; then
  for cmd_file in "$DOTFILES_CLAUDE/commands"/*.md; do
    if [ -f "$cmd_file" ]; then
      cmd_name=$(basename "$cmd_file")
      target="$CLAUDE_DIR/commands/$cmd_name"

      # Remove existing file/symlink
      if [ -e "$target" ] || [ -L "$target" ]; then
        rm "$target"
      fi

      ln -s "$cmd_file" "$target"
      echo "  Linked command: /$(basename "$cmd_name" .md)"
    fi
  done
fi

# Symlink skill directories
if [ -d "$DOTFILES_CLAUDE/skills" ]; then
  mkdir -p "$CLAUDE_DIR/skills"
  for skill_dir in "$DOTFILES_CLAUDE/skills"/*/; do
    if [ -d "$skill_dir" ]; then
      skill_name=$(basename "$skill_dir")
      target="$CLAUDE_DIR/skills/$skill_name"

      # Remove existing file/symlink/directory
      if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf "$target"
      fi

      ln -s "$skill_dir" "$target"
      echo "  Linked skill: $skill_name"
    fi
  done
fi

# Symlink global CLAUDE.md
if [ -f "$DOTFILES_CLAUDE/CLAUDE.md" ]; then
  if [ -e "$CLAUDE_DIR/CLAUDE.md" ] || [ -L "$CLAUDE_DIR/CLAUDE.md" ]; then
    rm "$CLAUDE_DIR/CLAUDE.md"
  fi
  ln -s "$DOTFILES_CLAUDE/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
  echo "  Linked CLAUDE.md"
fi

# Symlink hook scripts
if [ -d "$DOTFILES_CLAUDE/hooks" ]; then
  mkdir -p "$CLAUDE_DIR/hooks"
  for hook_file in "$DOTFILES_CLAUDE/hooks"/*; do
    if [ -f "$hook_file" ]; then
      target="$CLAUDE_DIR/hooks/$(basename "$hook_file")"
      if [ -e "$target" ] || [ -L "$target" ]; then
        rm "$target"
      fi
      chmod +x "$hook_file"
      ln -s "$hook_file" "$target"
      echo "  Linked hook: $(basename "$hook_file")"
    fi
  done
fi

# If settings.json doesn't exist, copy the template
if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
  cp "$DOTFILES_CLAUDE/settings.json.example" "$CLAUDE_DIR/settings.json"
  echo "  Created settings.json from template"
  echo "  → You may want to add your AWS profile and other machine-specific settings"
else
  echo "  settings.json already exists (not modified)"
  echo "  → Ensure it has statusLine.command set to ~/.claude/statusline.sh"
fi

# Ensure the Rex long-running command hook is registered in settings.json
REX_HOOK_CMD="~/.claude/hooks/rex-long-running.sh"
if command -v jq >/dev/null 2>&1; then
  if ! jq -e --arg c "$REX_HOOK_CMD" '[.hooks.PreToolUse[]?.hooks[]?.command] | index($c)' "$CLAUDE_DIR/settings.json" >/dev/null; then
    tmp=$(mktemp)
    jq --arg c "$REX_HOOK_CMD" '.hooks.PreToolUse = ((.hooks.PreToolUse // []) + [{"matcher":"Bash","hooks":[{"type":"command","command":$c,"timeout":5}]}])' \
      "$CLAUDE_DIR/settings.json" > "$tmp" && mv "$tmp" "$CLAUDE_DIR/settings.json"
    echo "  Registered rex-long-running hook in settings.json"
  fi
else
  echo "  jq not found: add the rex-long-running PreToolUse hook to settings.json manually"
fi
