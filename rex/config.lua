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
-- One Rex session per git worktree, in any repo under ~/Documents/Projects.
-- A worktree's session is labeled <repo>/<name>, so it is found again by name:
--
--   Edpuzzle-Web/main              the main checkout
--   Edpuzzle-Web/search-ranking    worktrees/Edpuzzle-Web/search-ranking
--   Edpuzzle-Web/badger-cli        a sibling such as Edpuzzle-Web-badger-cli
--
-- New worktrees go to worktrees/<repo>/<branch>, where `wt switch -c` puts them
-- too (worktrunk/config.toml). The palette prompts need rex.ui; from the CLI
-- every action also takes its answers as arguments (rex/worktree.zsh).

local home = os.getenv("HOME")
local projects_dir = home .. "/Documents/Projects"
local worktrees_dir = projects_dir .. "/worktrees"
local default_repo = projects_dir .. "/Edpuzzle-Web"

local function basename(path)
  return (path:gsub("/+$", ""):match("([^/]+)$"))
end

local function starts_with(s, prefix)
  return s:sub(1, #prefix) == prefix
end

-- Worktrunk's `sanitize` filter: path separators become dashes.
local function worktree_slug(branch)
  return (branch:gsub("[/\\]", "-"))
end

local function exec(argv, cwd)
  local r, err = rex.exec(argv, { cwd = cwd or "/", timeout = 25 })
  if r == nil then error(err, 0) end
  return r
end

local function git(args, cwd)
  local argv = { "git" }
  for _, a in ipairs(args) do argv[#argv + 1] = a end
  return exec(argv, cwd)
end

local function lines(s)
  local out = {}
  for line in (s or ""):gmatch("[^\n]+") do out[#out + 1] = line end
  return out
end

-- rex.ui is on the Bleeding Edge channel for now. Without it, the actions
-- still work when every answer comes in as an argument.
local function ask(kind, spec)
  if rex.ui == nil then
    error("this Rex has no rex.ui yet; pass the arguments instead (rex do ... key=value)", 0)
  end
  return rex.ui[kind](spec)
end

-- Repos are the folders under projects_dir whose .git is a directory, so
-- linked worktrees (whose .git is a file) don't show up as projects.
local function list_repos()
  local r = exec({ "find", projects_dir, "-mindepth", "2", "-maxdepth", "2",
                   "-name", ".git", "-type", "d" })
  local repos = {}
  for _, line in ipairs(lines(r.stdout)) do
    repos[#repos + 1] = line:gsub("/%.git$", "")
  end
  table.sort(repos, function(a, b) return a:lower() < b:lower() end)
  return repos
end

local function list_worktrees(repo)
  local r = git({ "worktree", "list", "--porcelain" }, repo)
  if not r.ok then error(r.stderr, 0) end
  local list, cur = {}, nil
  for _, line in ipairs(lines(r.stdout)) do
    local key, value = line:match("^(%S+)%s?(.*)$")
    if key == "worktree" then
      cur = { path = value }
      list[#list + 1] = cur
    elseif cur and key == "branch" then
      cur.branch = value:gsub("^refs/heads/", "")
    elseif cur and (key == "detached" or key == "bare" or key == "prunable") then
      cur[key] = true
    end
  end
  return list
end

-- The name half of a session label: stable for as long as the folder exists,
-- even when the worktree switches branches.
local function worktree_name(repo, path)
  local repo_name = basename(repo)
  if path == repo then return "main" end
  local managed = worktrees_dir .. "/" .. repo_name .. "/"
  if starts_with(path, managed) then return path:sub(#managed + 1) end
  local name = basename(path)
  for _, sep in ipairs({ "-", ".", "_" }) do
    if starts_with(name, repo_name .. sep) and #name > #repo_name + 1 then
      return name:sub(#repo_name + 2)
    end
  end
  return name
end

local function session_label(repo, path)
  return basename(repo) .. "/" .. worktree_name(repo, path)
end

local function sessions_by_label()
  local list, err = rex.call("session.list")
  if list == nil then error(err, 0) end
  local by_label = {}
  for _, s in ipairs(list.sessions or {}) do
    if s.label then by_label[s.label] = s.session_id end
  end
  return by_label
end

-- Only the app that ran the action can switch to the session. From the CLI the
-- request would fail unless Remote Control is on, so skip it there.
local function show_session(ctx, session_id)
  if ctx.origin == "key" or ctx.origin == "palette" then
    rex.client.queue("session.select", { session_id = session_id })
  end
end

-- Focus the worktree's session, creating it (Shell + Claude tabs) if needed.
local function open_worktree_session(ctx, repo, path)
  local label = session_label(repo, path)
  local existing = sessions_by_label()[label]
  if existing then
    show_session(ctx, existing)
    return { session_id = existing, label = label, dir = path, created = false }
  end

  local shell = "com.superlogical.terminal.shell"
  local s, err = rex.call("session.create", {
    label = label,
    initial_windows = {
      { window_label = "Shell", layout = { block = { flavor = shell, options = { cwd = path } } } },
      { window_label = "Claude", layout = { block = { flavor = shell, options = { cwd = path, command = { "claude" } } } } },
    },
  })
  if s == nil then error(err, 0) end
  show_session(ctx, s.session_id)
  return { session_id = s.session_id, label = label, dir = path, created = true }
end

local function close_session(label)
  local session_id = sessions_by_label()[label]
  if not session_id then return false end
  -- session.destroy only accepts sessions this connection is attached to.
  local _, err = rex.call("session.attach", { session_id = session_id })
  if err == nil then _, err = rex.call("session.destroy", { session_id = session_id }) end
  if err ~= nil then error("closing session " .. label .. " failed: " .. err, 0) end
  return true
end

local function pick_repo(args)
  if args.repo then
    return args.repo:find("/") and args.repo or (projects_dir .. "/" .. args.repo)
  end
  local items = {}
  for _, repo in ipairs(list_repos()) do
    local n = #list_worktrees(repo)
    items[#items + 1] = {
      id = repo, title = basename(repo), icon = "folder",
      subtitle = repo:gsub("^" .. home:gsub("%p", "%%%0"), "~"),
      detail = n > 1 and (n .. " worktrees") or nil,
    }
  end
  return ask("pick", { title = "Project", placeholder = "Filter projects", items = items })
end

-- Recent local branches, newest first, with master or main on top.
local function pick_base(repo)
  local r = git({ "for-each-ref", "--sort=-committerdate", "--count=50",
                  "--format=%(refname:short)", "refs/heads" }, repo)
  local items, seen = {}, {}
  for _, b in ipairs({ "master", "main" }) do
    if git({ "rev-parse", "--verify", "--quiet", "refs/heads/" .. b }, repo).ok then
      items[#items + 1] = { id = b, icon = "star" }
      seen[b] = true
    end
  end
  for _, b in ipairs(lines(r.stdout)) do
    if not seen[b] then items[#items + 1] = { id = b, icon = "branch" } end
  end
  local base = ask("pick", { title = "Base branch", placeholder = "Filter branches",
                             items = items, allow_other = true })
  if type(base) == "table" then base = base.text end
  return base
end

-- Create (or find) the worktree for a branch and return its path.
local function ensure_worktree(repo, branch, base)
  for _, wt in ipairs(list_worktrees(repo)) do
    if wt.branch == branch then return wt.path end
  end
  local dir = worktrees_dir .. "/" .. basename(repo) .. "/" .. worktree_slug(branch)
  local add
  if git({ "rev-parse", "--verify", "--quiet", "refs/heads/" .. branch }, repo).ok then
    add = git({ "worktree", "add", dir, branch }, repo)
  else
    add = git({ "worktree", "add", "-b", branch, dir, base or "master" }, repo)
  end
  if not add.ok then error(add.stderr, 0) end
  return dir
end

local function new_worktree(ctx, repo, branch, base)
  if branch == nil then
    branch = ask("input", { title = "New branch in " .. basename(repo),
                            placeholder = "area__short-description", confirm = "Next" })
    if branch == nil or branch == "" then return end
  end
  if base == nil and not git({ "rev-parse", "--verify", "--quiet",
                               "refs/heads/" .. branch }, repo).ok then
    base = pick_base(repo)
    if base == nil then return end
  end
  return open_worktree_session(ctx, repo, ensure_worktree(repo, branch, base))
end

rex.action{
  name        = "worktree_open",
  title       = "Worktree: Open…",
  description = "Pick a project and one of its worktrees, and switch to that worktree's session, creating it if needed. Type a branch name to create a new worktree.",
  keywords    = "git branch task session switch project",
  args        = { repo = "string?", path = "string?" },
  run         = function(ctx, args)
    local repo = pick_repo(args)
    if repo == nil then return end

    local path = args.path
    if path == nil then
      local open = sessions_by_label()
      local items = { { id = "+new", title = "New worktree…", icon = "plus" } }
      for _, wt in ipairs(list_worktrees(repo)) do
        if not wt.bare and not wt.prunable then
          items[#items + 1] = {
            id       = wt.path,
            title    = worktree_name(repo, wt.path),
            subtitle = wt.branch or "detached HEAD",
            icon     = wt.path == repo and "folder" or "branch",
            detail   = open[session_label(repo, wt.path)] and "● session" or nil,
          }
        end
      end
      local choice = ask("pick", {
        title = basename(repo) .. " worktrees", items = items, allow_other = true,
        placeholder = "Filter, or type a new branch name",
      })
      if choice == nil then return end
      if choice == "+new" then return new_worktree(ctx, repo) end
      if type(choice) == "table" then return new_worktree(ctx, repo, choice.text) end
      path = choice
    end
    return open_worktree_session(ctx, repo, path)
  end,
}

rex.action{
  name        = "worktree_new",
  title       = "Worktree: New…",
  description = "Create a git worktree for a branch and open a session with Claude in it.",
  keywords    = "git branch task",
  args        = { branch = "string?", base = "string?", repo = "string?" },
  run         = function(ctx, args)
    -- Without a repo from the CLI, keep the old default instead of asking.
    if args.repo == nil and args.branch ~= nil then args.repo = default_repo end
    local repo = pick_repo(args)
    if repo == nil then return end
    return new_worktree(ctx, repo, args.branch, args.base)
  end,
}

rex.action{
  name        = "worktree_remove",
  title       = "Worktree: Remove…",
  description = "Remove worktrees and close their sessions. Refuses a worktree with uncommitted changes. Keeps the branches.",
  keywords    = "git branch task delete close",
  args        = { branch = "string?", repo = "string?" },
  run         = function(ctx, args)
    if args.repo == nil and args.branch ~= nil then args.repo = default_repo end
    local repo = pick_repo(args)
    if repo == nil then return end

    local worktrees = list_worktrees(repo)
    local paths = {}
    if args.branch then
      for _, wt in ipairs(worktrees) do
        if wt.branch == args.branch then paths[1] = wt.path end
      end
      if #paths == 0 then error("no worktree has branch " .. args.branch, 0) end
    else
      local items = {}
      for _, wt in ipairs(worktrees) do
        if wt.path ~= repo and not wt.bare then
          local dirty = not wt.prunable
            and git({ "status", "--porcelain" }, wt.path).stdout ~= ""
          items[#items + 1] = {
            id = wt.path, title = worktree_name(repo, wt.path),
            subtitle = wt.branch or "detached HEAD", icon = "branch",
            detail = wt.prunable and "missing" or (dirty and "changes" or nil),
          }
        end
      end
      paths = ask("pick", { title = "Remove worktrees", multiple = true,
                            confirm = "Remove", items = items })
      if paths == nil or #paths == 0 then return end
    end

    local removed, failed = {}, {}
    for _, path in ipairs(paths) do
      local r = git({ "worktree", "remove", path }, repo)
      if r.ok then
        close_session(session_label(repo, path))
        removed[#removed + 1] = path
      else
        failed[#failed + 1] = path .. ": " .. r.stderr
      end
    end
    if #failed > 0 then error(table.concat(failed, "\n"), 0) end
    return { removed = removed }
  end,
}

rex.bind("ctrl+a>w", "worktree_open")
