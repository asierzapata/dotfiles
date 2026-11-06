#!/bin/bash
# PreToolUse hook (Bash): when running inside Rex, block long-running commands
# and tell Claude to open them in a Rex tab so the user can watch them.

[ -z "$REX_SESSION" ] && exit 0

cmd=$(jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

# Already being launched through Rex: allow.
if printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])rex[[:space:]]+(window[[:space:]]+new|run|split|new)([[:space:]]|$)'; then
  exit 0
fi

end='([[:space:];&|)]|$)'
patterns=(
  # npm/pnpm/yarn/bun dev servers, incl. Edpuzzle: client, server, server:localhost
  "(npm|pnpm|yarn|bun)([[:space:]]+run)?[[:space:]]+(dev|start|serve|watch|client|server(:localhost)?)${end}"
  "(^|[[:space:];&|])(npx[[:space:]]+)?(vite|next[[:space:]]+dev|nodemon|webpack[[:space:]]+serve|webpack-dev-server)${end}"
  "tail[[:space:]]+(-[a-zA-Z]*f|--follow)"
  "(^|[[:space:];&|])(cargo[[:space:]]+watch|tsc[[:space:]].*(-w|--watch))${end}"
)

match=0
for p in "${patterns[@]}"; do
  if printf '%s' "$cmd" | grep -Eq -- "$p"; then match=1; break; fi
done

# docker compose up without detach
if [ $match -eq 0 ] && printf '%s' "$cmd" | grep -Eq 'docker[- ]compose([[:space:]]+[^;&|]*)?[[:space:]]up' \
   && ! printf '%s' "$cmd" | grep -Eq '[[:space:]](-d|--detach)([[:space:]]|$)'; then
  match=1
fi

[ $match -eq 0 ] && exit 0

cat >&2 <<EOF
Blocked: this looks like a long-running command. The user wants these in a visible Rex tab, not the Bash tool.
Run it with:
  rex window new -s "\$REX_SESSION" <TabName> -c <project_dir> --keep-open --focus=false --json -- <command>
Then confirm it started with: rex capture -s "\$REX_SESSION" -b <block_id> --trim | tail -n 50
Command was: $cmd
EOF
exit 2
