---
name: pr-stack-description
description: Add or update a PR stack navigation block in the description of every PR in a stack. Use when the user wants to label, annotate, or add stack info to PR descriptions so reviewers can see the full stack and where each PR sits.
---

# PR Stack Description

Appends a navigational "PR Stack" block to the description of every PR in a stacked chain, so reviewers can see the full stack and which PR they're looking at.

## When to Use

- User wants to add stack info to PR descriptions
- User mentions "label the stack", "add stack to descriptions", "annotate PRs with stack"
- User has a chain of dependent PRs and wants reviewers to understand the ordering

## Workflow

### Step 1: Identify the Stack

Starting from the current branch (or a branch/PR the user provides), walk the `baseRefName` chain to discover the full ordered stack:

```bash
gh pr list --author @me --state open --json number,title,headRefName,baseRefName
```

Build an ordered list from bottom (base = master/main) to top. The bottom PR is #1 in the stack.

Confirm the discovered stack with the user before making any edits.

### Step 2: Update Each PR Description

For each PR in the stack, **append** (do not prepend) the following block to the existing body. If a stack block already exists (detect by the `> **PR Stack` marker), **replace** it instead of appending a duplicate.

Format:

```markdown

---

> **PR Stack (POSITION/TOTAL)**
> 1. #NUMBER — Title
> 2. **#NUMBER — Title** <-- this PR
> 3. #NUMBER — Title
```

Rules:
- The current PR's line is **bolded** and has the ` <-- this PR` suffix
- PR numbers use the `#NUMBER` format so GitHub auto-links them
- The `---` horizontal rule separates the stack block from the rest of the description

### Step 3: Apply Updates

For each PR, fetch the current body, append/replace the stack block, and update:

```bash
ORIGINAL=$(gh pr view <number> --json body -q '.body')
# Remove existing stack block if present (everything after the last "---\n\n> **PR Stack")
# Append new stack block
gh pr edit <number> --body "${NEW_BODY}"
```

### Step 4: Report

List all updated PRs with their URLs.

## Important Notes

- **Append, don't prepend** — the stack block goes at the end of the PR description
- **Idempotent** — running again replaces the existing stack block rather than adding a duplicate
- **Confirm first** — always show the discovered stack to the user before editing any PR descriptions
- **Preserve existing content** — never modify the original PR description content, only add/replace the stack block at the end
