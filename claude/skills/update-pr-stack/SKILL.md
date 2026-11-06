---
name: update-pr-stack
description: Update a GitHub stack of dependent PRs with `gh stack`, either to bring in the latest base branch (usually master) or to propagate a fix made on a lower PR to the PRs above it. Use when the user wants to update, sync, refresh, or rebase a PR stack, or to carry a change up the stack.
---

# Update PR Stack

Updates a stack of dependent PRs with the `gh stack` extension (`github/gh-stack`): a cascading rebase of each branch onto its parent, then one atomic push.

## When to use

- The user wants to bring the latest master into a stack.
- The user changed a lower PR (for example, to address review comments) and wants the PRs above it to include the change.
- The user gives a stack URL (`https://github.com/<owner>/<repo>/stack/<number>`), a PR number, or a branch that is part of a stack.

## Workflow

### 1. Load the stack

```bash
gh stack view                    # when the current branch is already in a tracked stack
gh stack checkout <stack-or-pr>  # otherwise; accepts a stack number, PR number, PR URL, or branch
```

A stack number from the URL also works with `gh api repos/<owner>/<repo>/stacks/<number>` when you only need the PR list. Do not assume a branch-naming convention to find the stack; use what `gh stack` reports. Confirm the order (bottom to top) and the goal with the user: bring in master, or only propagate a change between the stack's branches.

### 2. Check the working tree

`gh stack rebase` refuses to run with uncommitted changes, including untracked files. If `git status --short` is not empty, ask the user whether to stash (`git stash push -u -m "update-pr-stack"`, then `git stash pop` at the end), or whether they want to handle it themselves. Do not stash without asking, and do not create a worktree for this.

### 3. Bring in commits that exist only on the remote

Reviewers sometimes apply suggestions in the GitHub UI, and CI may push formatting commits. The rebase works on local branches, and the push uses `--force-with-lease` against what was just fetched, so a remote-only commit would be silently dropped.

```bash
git fetch origin
for b in <stack branches>; do
  echo "$b local-only: $(git rev-list --count origin/$b..$b) remote-only: $(git rev-list --count $b..origin/$b)"
done
```

- Remote-only commits and no local-only commits: fast-forward with `git branch -f <b> origin/<b>`, or `git merge --ff-only` on the current branch.
- Commits on both sides: stop and ask the user how to reconcile them.

### 4. Check for merge commits

```bash
git log --merges --oneline <trunk>..<top branch>
```

If the stack was previously updated by merging parents into children, `gh stack rebase` replays each commit one by one and the conflicts already resolved in those merges come back. In that case, stop and offer to flatten each PR into one commit first (step 5). Flattening rewrites published branches and drops the per-commit history inside each PR, so it needs the user's explicit approval. If there are no merge commits, skip to step 6.

### 5. Flatten each PR into one commit (only with approval)

Rebuild the stack bottom-up with `git merge-tree`, so each new commit has exactly the old branch's content plus whatever changed below it. Save the old heads and each PR's diff first, so you can verify the result and restore it.

```bash
# For each branch Bi above the bottom one, bottom to top:
#   OLD_PARENT = the version of the parent that Bi currently contains: git merge-base <parent> <Bi>
#   NEW_PARENT = the parent's new head (for the first branch above a changed bottom PR, the bottom PR's head)
T=$(git merge-tree --write-tree --merge-base "$OLD_PARENT" "$NEW_PARENT" "$Bi")
N=$(git commit-tree "$T" -p "$NEW_PARENT" -m "<PR title>")
```

`OLD_PARENT` matters when a parent got commits that the child never merged, such as a GitHub UI suggestion. Use `merge-base`, not the parent's current head, or the child's diff will revert them.

Before moving any branch, check that each PR's diff is unchanged apart from what you are propagating. Compare `git diff <new parent> <new head>` with the saved diff, ignoring `index` lines and hunk line numbers. Then move the branches with `git branch -f <b> <new commit>`. If `git merge-tree` reports a conflict, stop and report it.

### 6. Rebase and push

```bash
gh stack rebase --no-trunk   # only propagate changes between the stack's branches
gh stack rebase              # also pull and rebase onto the trunk (master)
gh stack push                # atomic, --force-with-lease per branch
```

Use `--upstack` or `--downstack` to limit the rebase to part of the stack. If the bottom PR was squash-merged and GitHub retargeted the stack, `gh stack rebase` rebases onto the new base. It asks before dropping commits from an old base that did not merge (`--accept-base-change` skips the prompt).

On a conflict, `gh stack rebase` stops and lists the conflicted files. Report them to the user, and resolve only what they ask for. Then run `git add` and `gh stack rebase --continue`, or `gh stack rebase --abort` to restore every branch.

Do not use `gh stack sync` as a shortcut for steps 3 to 6. It pushes right after the rebase, and you lose the chance to check for remote-only commits and verify the result first.

### 7. Verify and report

- `git ls-remote origin <branch>` matches the local head for every branch.
- Run the tests that cover the propagated change, or say they were not run.
- Pop the stash if you created one.

Report which PRs changed, whether history was flattened, any remote-only commits you brought in, and whether master was included.
