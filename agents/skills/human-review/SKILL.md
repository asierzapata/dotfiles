---
name: human-review
description: Let Asier review a change himself, visually, in leaf. Opens the diff in a pane beside yours, then works through the review he sends back, answering, changing code, and reopening the review until he approves. Use when Asier runs /human-review, or wants to review, look at, or go through a change, branch, commit, diff or pull request himself, "in leaf", "visually", "with comments", or "together", or when you finish a change he asked to review. Not for an automated review by an agent, which is review-change or code-review.
argument-hint: "[uncommitted | staged | <ref> | <from>..<to> | <pr url>] [-- <pathspec>]"
---

# Human review in leaf

Asier reviews the diff in leaf, a terminal diff viewer, and sends his notes back as one review with a verdict. Your job is to open the right diff, act on every note in the review, and reopen it until he approves. leaf is his UI: run `leaf review` from your shell, which opens it in a pane beside yours, and never run `leaf diff` or a bare `leaf` there, since your shell has no terminal.

## 1. Choose what to review

Use the argument when there is one:

- No argument: the whole branch, meaning committed and uncommitted changes, against the remote default branch. Use `--branch --base origin/<default>`, with the default from `git symbolic-ref --short refs/remotes/origin/HEAD` (fall back to `origin/master` or `origin/main`). Don't diff against the local default branch, because a stale local `master` adds hundreds of unrelated files. Run `git fetch origin <default>` first only if the result looks wrong.
- `uncommitted`: no target, which reviews unstaged changes.
- `staged`: `--staged`.
- A ref or a range: pass it through as it is, such as `main...HEAD`.
- A pull request URL: pass it through.
- Anything after `--` is a pathspec that limits the files.

Before opening, check with `git diff --stat <target>` that the file count is plausible for the change. If it is not, say so and fix the target instead of opening a misleading diff. Make sure the change builds and its tests pass, so the review is about the change and not broken code.

## 2. Open it

```sh
leaf review [target] [-- <pathspec>]
```

Inside Rex, this opens the review in a pane beside yours and returns at once with "Opened the changes for review". Tell him in one or two sentences what the review covers: how many files, and what it is compared against.

Then **end your turn**. Don't wait, sleep, poll or read the pane. His review arrives as your next message.

If leaf says there is nowhere to open it (you are not in Rex, tmux or Herdr), tell him the exact command to run in his terminal. In a script that has to block, `leaf review --wait …` prints the review to stdout when he sends it.

## 3. Questions during the review

While he reviews, he can select lines and press `@`, which pastes a question into your pane with the file, line numbers and the diff around them. Treat it as his message and answer it in the conversation. Don't change code for it unless he asks; his review is still open.

## 4. Work through the review

The review is one message headed `# Review of …: <verdict>`, grouped by file in diff order. A `Global:` note is on the whole change. A whole-file note comes before that file's line notes, and each line note quotes the hunk it is on. "Old side" line numbers refer to the file before the change, and "new side" to after.

Read the code around each note before acting on it. Treat notes in order, and group the ones that ask for the same change:

- A question: answer it in your reply, in a few sentences.
- A change request that is clear: make the change.
- A change request that is ambiguous, or that would expand the scope of the branch: don't change code. Give the options and your recommendation, and wait.
- A disagreement: if you think the request is wrong, say why and don't make the change until he confirms.

Then act on the verdict:

- **approved**: the change is done. Go to step 6.
- **approved with notes**: apply every numbered item, then go to step 6.
- **changes requested**: address every numbered item, then go to step 5.

If the message says the review was closed without a verdict, ask him how he'd like to go on.

In the conversation, give a short summary by note number: which ones you changed code for, which you only answered, and which wait for his decision. Don't repeat the notes back.

## 5. Next round

Run the checks that can catch a plausible failure in what you changed, such as the spec next to the edited file or the linter. Then run the same `leaf review` command again, so he sees the new diff, and end your turn. Repeat steps 4 and 5 until he approves.

## 6. Finish

- Don't commit, push, or open a PR unless he asks. If he asks, follow the repository's rules for commits and PRs.
- The leaf pane closes when he sends the review. Saved comments stay in leaf's store; `leaf comments --json` lists them if you need them again.
