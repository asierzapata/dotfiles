-- Rex configuration, migrated from tmux (~/.config/tmux/tmux.conf) and
-- zellij (~/.config/zellij/config.kdl). Ghostty, kitty and Alacritty had no
-- key bindings to migrate.

-- tmux ---------------------------------------------------------------------
-- Prefix ctrl+a: every tmux binding is a ctrl+a sequence.
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })

-- zellij -------------------------------------------------------------------
-- keybinds clear-defaults=true: only the file's bindings are migrated.

rex.action{
  name  = "then_normal",
  title = "Run an action and return to normal mode",
  args  = { action = "string", args = "object?" },
  run   = function(ctx, args)
    rex.client.queue(args.action, args.args or {})
    rex.client.queue("client.mode.exit_all")
  end,
}

-- Modes the user stays in until leaving them. Locked is not exclusive: in
-- zellij every key in locked mode reaches the terminal.
for _, mode in ipairs({ "pane", "tab", "resize", "move", "scroll", "session", "tmux" }) do
  rex.mode(mode, { exclusive = true })
end

local enter_keys = {
  ["ctrl+g"] = "locked",
  ["ctrl+p"] = "pane",
  ["ctrl+t"] = "tab",
  ["ctrl+n"] = "resize",
  ["ctrl+h"] = "move",
  ["ctrl+s"] = "scroll",
  ["ctrl+o"] = "session",
  ["ctrl+b"] = "tmux",
}

local alt_focus = {
  ["alt+left"] = "left", ["alt+h"] = "left",
  ["alt+down"] = "down", ["alt+j"] = "down",
  ["alt+up"] = "up", ["alt+k"] = "up",
  ["alt+right"] = "right", ["alt+l"] = "right",
}

-- Normal mode, and the shared_except "locked" ... blocks in every mode they
-- apply to. A mode's own key (ctrl+p in pane, ...) leaves it instead.
local function shared(prefix, mode)
  rex.bind(prefix .. "alt+i", "client.tab.move", { direction = "backward" })
  rex.bind(prefix .. "alt+o", "client.tab.move", { direction = "forward" })
  rex.bind(prefix .. "alt+n", "pane.split.auto")
  for key, target in pairs(enter_keys) do
    if target == mode then
      rex.bind(prefix .. key, "client.mode.exit_all")
    elseif not (mode == "scroll" and key == "ctrl+b") then
      rex.bind(prefix .. key, "client.mode.enter", { name = target })
    end
  end
  if mode ~= "scroll" then
    for key, direction in pairs(alt_focus) do
      rex.bind(prefix .. key, "pane.focus", { direction = direction })
    end
  end
  if mode then
    rex.bind(prefix .. "enter", "client.mode.exit_all")
    rex.bind(prefix .. "esc", "client.mode.exit_all")
  end
end

shared("", nil)
for _, mode in ipairs({ "pane", "tab", "resize", "move", "scroll", "session", "tmux" }) do
  shared(mode .. "/", mode)
end

-- locked
rex.bind("locked/ctrl+g", "client.mode.exit_all")

-- pane
for key, direction in pairs({ left = "left", h = "left", down = "down", j = "down",
                              up = "up", k = "up", right = "right", l = "right" }) do
  rex.bind("pane/" .. key, "pane.focus", { direction = direction })
end
rex.bind("pane/c", "then_normal", { action = "pane.rename" })
rex.bind("pane/d", "then_normal", { action = "pane.split", args = { direction = "down" } })
rex.bind("pane/f", "then_normal", { action = "pane.zoom" })
rex.bind("pane/n", "then_normal", { action = "pane.split", args = { direction = "auto" } })
rex.bind("pane/p", "pane.focus_next")
rex.bind("pane/r", "then_normal", { action = "pane.split", args = { direction = "right" } })
rex.bind("pane/x", "then_normal", { action = "pane.close" })

-- tab
for _, key in ipairs({ "left", "up", "h", "k" }) do
  rex.bind("tab/" .. key, "client.tab.previous")
end
for _, key in ipairs({ "down", "right", "j", "l" }) do
  rex.bind("tab/" .. key, "client.tab.next")
end
for i = 1, 9 do
  rex.bind("tab/" .. i, "then_normal", { action = "client.tab.goto", args = { index = i } })
end
rex.bind("tab/b", "then_normal", { action = "pane.move_to_new_tab" })
rex.bind("tab/n", "then_normal", { action = "client.tab.new" })
rex.bind("tab/r", "then_normal", { action = "client.tab.rename" })
rex.bind("tab/x", "then_normal", { action = "client.tab.close" })

-- resize
for key, direction in pairs({ left = "left", h = "left", down = "down", j = "down",
                              up = "up", k = "up", right = "right", l = "right" }) do
  rex.bind("resize/" .. key, "pane.resize", { direction = direction })
end

-- move
for key, direction in pairs({ left = "left", h = "left", down = "down", j = "down",
                              up = "up", k = "up", right = "right", l = "right" }) do
  rex.bind("move/" .. key, "pane.move", { direction = direction })
end

-- scroll
for key, direction in pairs(alt_focus) do
  rex.bind("scroll/" .. key, "then_normal", { action = "pane.focus", args = { direction = direction } })
end

-- tmux
for key, direction in pairs({ left = "left", h = "left", down = "down", j = "down",
                              up = "up", k = "up", right = "right", l = "right" }) do
  rex.bind("tmux/" .. key, "then_normal", { action = "pane.focus", args = { direction = direction } })
end
rex.bind("tmux/shift+'", "then_normal", { action = "pane.split", args = { direction = "down" } })
rex.bind("tmux/shift+5", "then_normal", { action = "pane.split", args = { direction = "right" } })
rex.bind("tmux/,", "then_normal", { action = "client.tab.rename" })
rex.bind("tmux/[", "client.mode.enter", { name = "scroll" })
rex.bind("tmux/ctrl+b", "then_normal", { action = "pane.send_key", args = { key = "ctrl+b" } })
rex.bind("tmux/c", "then_normal", { action = "client.tab.new" })
rex.bind("tmux/n", "then_normal", { action = "client.tab.next" })
rex.bind("tmux/o", "pane.focus_next")
rex.bind("tmux/p", "then_normal", { action = "client.tab.previous" })
rex.bind("tmux/z", "then_normal", { action = "pane.zoom" })
rex.bind("tmux/x", "then_normal", { action = "pane.close" })

-- Worktrees ----------------------------------------------------------------
-- One git worktree per task, each in its own session labeled after the branch.

local worktree_repo = os.getenv("HOME") .. "/Documents/Projects/Edpuzzle-Web"
local worktree_root = os.getenv("HOME") .. "/Documents/Projects/worktrees/Edpuzzle-Web"

local function worktree_slug(branch)
  return (branch:gsub("/", "-"))
end

local function git(args, cwd)
  local argv = { "git" }
  for _, a in ipairs(args) do argv[#argv + 1] = a end
  local r, err = rex.exec(argv, { cwd = cwd or worktree_repo, timeout = 25 })
  if r == nil then error(err, 0) end
  return r
end

local function find_session(label)
  local list, err = rex.call("session.list")
  if list == nil then error(err, 0) end
  for _, s in ipairs(list.sessions or {}) do
    if s.label == label then return s.session_id end
  end
end

-- Only the app that ran the action can switch to the session. From the CLI the
-- request would fail unless Remote Control is on, so skip it there.
local function show_session(ctx, session_id)
  if ctx.origin == "key" or ctx.origin == "palette" then
    rex.client.queue("session.select", { session_id = session_id })
  end
end

rex.action{
  name        = "worktree_new",
  title       = "New Worktree Session",
  description = "Create a git worktree for a branch and open a session with Claude in it.",
  keywords    = "git branch task",
  args        = { branch = "string", base = "string?" },
  run         = function(ctx, args)
    local slug = worktree_slug(args.branch)
    local dir = worktree_root .. "/" .. slug

    local existing = find_session(slug)
    if existing then
      show_session(ctx, existing)
      return { session_id = existing, dir = dir, created = false }
    end

    if not git({ "-C", dir, "rev-parse", "--git-dir" }, "/").ok then
      local add
      if git({ "rev-parse", "--verify", "--quiet", "refs/heads/" .. args.branch }).ok then
        add = git({ "worktree", "add", dir, args.branch })
      else
        add = git({ "worktree", "add", "-b", args.branch, dir, args.base or "master" })
      end
      if not add.ok then error(add.stderr, 0) end
    end

    local shell = "com.superlogical.terminal.shell"
    local s, err = rex.call("session.create", {
      label = slug,
      initial_windows = {
        { window_label = "Shell", layout = { block = { flavor = shell, options = { cwd = dir } } } },
        { window_label = "Claude", layout = { block = { flavor = shell, options = { cwd = dir, command = { "claude" } } } } },
      },
    })
    if s == nil then error(err, 0) end
    show_session(ctx, s.session_id)
    return { session_id = s.session_id, dir = dir, created = true }
  end,
}

rex.action{
  name        = "worktree_remove",
  title       = "Remove Worktree Session",
  description = "Remove a branch's worktree and close its session. Refuses when the worktree has uncommitted changes. Keeps the branch.",
  keywords    = "git branch task delete close",
  args        = { branch = "string" },
  run         = function(ctx, args)
    local slug = worktree_slug(args.branch)
    local dir = worktree_root .. "/" .. slug

    local r = git({ "worktree", "remove", dir })
    if not r.ok then error(r.stderr, 0) end

    local session_id = find_session(slug)
    if session_id then
      -- session.destroy only accepts sessions this connection is attached to.
      local _, err = rex.call("session.attach", { session_id = session_id })
      if err == nil then _, err = rex.call("session.destroy", { session_id = session_id }) end
      if err ~= nil then error("worktree removed, but closing the session failed: " .. err, 0) end
    end
    return { removed = dir, session_closed = session_id ~= nil }
  end,
}
