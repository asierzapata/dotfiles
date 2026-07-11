---
name: update-pr-stack
description: Update a stack of dependent PRs by merging the latest base branch (usually master) down through each branch in order. Use when the user wants to update, sync, or refresh a stack of PRs with the latest changes from master.
---

# Update PR Stack

Propagates base branch updates through a stack of dependent PRs by merging (not rebasing) from the bottom up.

## When to Use

- User wants to update a PR stack with the latest master
- User mentions "update the stack", "sync the stack", "propagate master"
- User provides a PR URL or branch name that is part of a stack

## Why Merge, Not Rebase

Stacked PRs in repos that use **squash-and-merge** must be updated via merge, not rebase. Rebasing tries to replay every individual commit from the branch, but squash-merged commits appear as a single new commit on master — so git can't match them, causing massive spurious conflicts. Merging avoids this entirely.

## Workflow

### Step 1: Identify the Stack

Starting from the PR the user provides, walk the `baseRefName` chain to find the full stack:

```bash
gh pr list --author <user> --state open --json number,title,headRefName,baseRefName
```

Build an ordered list from bottom (base = master) to top. Confirm the stack with the user before proceeding.

### Step 2: Fetch Latest Base

```bash
git fetch origin master
```

### Step 3: Merge Up the Stack

For each branch, bottom to top:

1. `git checkout <branch>`
2. `git merge <previous-branch-or-origin/master>` (use `origin/master` for the first branch)
3. If clean: `git push origin <branch>`
4. If conflicts: stop and report to the user. Let them decide how to resolve before continuing.

### Step 4: Report

Summarize what was done: which branches were updated, whether any had conflicts.

## Important Notes

- **Never rebase** — always merge. See "Why Merge, Not Rebase" above.
- **Stop on conflicts** — don't auto-resolve. Report the conflicted files and let the user decide.
- **Push after each branch** — so downstream branches see the update when merging.
- The stack order matters: always go bottom-up (closest to master first).
