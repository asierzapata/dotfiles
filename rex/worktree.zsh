# Worktree sessions from the shell, using the worktree_new and worktree_remove
# actions in rex/init.lua, so the worktree, the branch and the Rex session share
# one name.
#
#   wtn master__search-ranking [base]   create or reuse, and show the session
#   wtrm master__search-ranking         remove the worktree and close the session

# The CLI can't switch the app to a session by itself, so ask the app client.
_rex_show_session() {
  local app
  app=$(rex client ls --json | jq -r '[.clients[] | select(.info.kind == "app")][0].client_id // empty')
  [[ -n $app ]] && rex -C "$app" do session.select session_id="$1" >/dev/null
}

wtn() {
  if [[ -z $1 ]]; then
    echo "usage: wtn <branch> [base]" >&2
    return 1
  fi
  local args=(branch="$1")
  [[ -n $2 ]] && args+=(base="$2")
  local result
  result=$(rex do worktree_new "${args[@]}" --json) || return
  _rex_show_session "$(jq -r '.session_id' <<<"$result")"
  jq -r 'if .created then "Created \(.dir)" else "Reusing \(.dir)" end' <<<"$result"
}

wtrm() {
  if [[ -z $1 ]]; then
    echo "usage: wtrm <branch>" >&2
    return 1
  fi
  rex do worktree_remove branch="$1"
}
