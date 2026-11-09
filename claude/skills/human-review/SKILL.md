---
name: human-review
description: Let Asier review a change himself, visually, in Hunk. Opens the diff in a new Rex tab, then iterates with him on the inline comments he leaves there, answering, changing code, and leaving agent notes on the lines. Use when Asier runs /human-review, or wants to review, look at, or go through a change, branch, commit, or diff himself, "in Hunk", "visually", "with comments", or "together". Not for an automated review by an agent, which is review-change or code-review.
argument-hint: "[uncommitted | <ref> | <from>..<to>] [-- <pathspec>]"
---

# Human review in Hunk

Asier reviews the diff in Hunk, a terminal diff viewer, and leaves inline comments there. Your job is to open the diff, read those comments, answer or act on each one in the same place, and keep the view current while you iterate. Hunk is his UI: never run `hunk diff` or `hunk show` in your own shell, only through Rex in a new tab. Control the open session with `hunk session *`.

Run `hunk skill path` and read that file once per session for the full `hunk session` reference. This skill only covers the workflow.

## 1. Choose what to diff

Use the argument when there is one:

- No argument: the whole branch, meaning committed and uncommitted changes. Diff against the merge base with the remote default branch, not the local one, because a stale local `master` adds hundreds of unrelated files. Get it with `git merge-base origin/HEAD HEAD`, falling back to `origin/master` or `origin/main`. Run `git fetch origin <default>` first only if the merge base looks wrong.
- `uncommitted`: `hunk diff` with no target.
- A ref or a range: pass it through as it is.
- Anything after `--` is a pathspec that limits the files.

Before opening, check with `git diff --stat <target>` that the file count is plausible for the change. If it is not, say so and fix the target instead of opening a misleading diff.

## 2. Open it in a new Rex tab

Load the `rex` skill if this session has not used Rex yet. Then open a tab in your own session, named after the branch:

```sh
rex window new -s "$REX_SESSION" "Review: <branch>" -c "<repo root>" --json -- hunk diff <target> [-- <pathspec>]
```

Save the returned `window_id` and `block_ids[0]`. Wait a second, then find the session with `hunk session list --json` and match it by `repoRoot`. If more than one session matches the repo, use the newest `launchedAt` and pass its `sessionId` to every later command instead of `--repo`. Confirm the tab rendered with `rex capture -s "$REX_SESSION" -b <block> --trim | head -3` and check the file count in its header.

If Asier already has a Hunk session for this repo, reuse it with `hunk session reload ... -- diff <target>` instead of opening a second tab.

Then tell him the tab is open, how many files and lines it covers, and what it is compared against, in one or two sentences. Ask him to leave comments in Hunk and tell you when he is done. Do not start reading comments on your own until he says so.

## 3. Read his comments

When he says he is done, list his notes:

```sh
hunk session comment list <session> --type user --json
```

Always pass `--type user`. Without it, the listing shows only agent notes, such as review-change findings and your own replies, and his notes are missing from it. An empty or agent-only result is not proof that he left no comments.

Read the code around each note before answering, with `hunk session review <session> --include-patch --json` for the files involved, or by reading the files. Comments can be questions, change requests, or remarks. Treat them in file order, and group comments that ask for the same change.

## 4. Answer in Hunk

Reply to every note in Hunk, so the conversation stays next to the code:

```sh
hunk session comment add <session> --reply-to <note-id> --summary "<answer>" --author Claude
```

- A question: answer it in the reply. Keep it to a few sentences.
- A change request that is clear: make the change, then reply with what you changed in one sentence.
- A change request that is ambiguous, or that would expand the scope of the branch: do not change code. Reply with the options and your recommendation, and wait.
- A disagreement: if you think the request is wrong, say why in the reply and do not make the change until he confirms.

Prefer one `hunk session comment apply <session> --stdin` batch when you have several replies ready. Never delete or edit his notes.

### Leave your own notes

Hunk shows agent notes by default, so you can also start a note on a line instead of only replying. Use one when something in the diff needs his attention: a change you made on a line he did not comment on, a risk you spotted, or a decision he should confirm. Anchor it to the line in the new version, or use `--old-line` for a deleted line:

```sh
hunk session comment add <session> --file <path> --new-line <n> --summary "<one-line point>" --rationale "<why, if it needs more>" --author Claude
```

For several notes, send one batch. Each item has `summary` and either `replyTo` alone, or `filePath` with one of `newLine`, `oldLine`, or `hunk`:

```sh
printf '%s\n' '{"comments":[{"filePath":"src/a.js","newLine":42,"summary":"...","rationale":"...","author":"Claude"}]}' | hunk session comment apply <session> --stdin
```

Keep the summary to one line and put the explanation in the rationale. Add `--focus` only when you want to move his view to the note. Do not repeat in a note what a reply already says.

In the conversation, give a short summary: which comments you changed code for, which you only answered, and which wait for his decision. Do not repeat the replies.

## 5. Refresh and iterate

After changing code, reload the session with the same target so he sees the new diff:

```sh
hunk session reload <session> -- diff <target> [-- <pathspec>]
```

A reload can drop notes on lines that changed. If his notes disappear after a reload, mention which ones were resolved by the change. When a reply concerns a specific line, `hunk session navigate <session> --file <path> --new-line <n>` moves his view there.

Run the checks that can catch a plausible failure in what you changed, such as the spec next to the edited file or the linter, before saying that a round is ready. Then wait for his next round of comments and repeat steps 3 to 5.

## 6. Finish

When he says the review is done:

- Do not commit, push, or open a PR unless he asks. If he asks, follow the repository's rules for commits and PRs.
- Close the Hunk tab only if he asks, with `rex window close <window_id>`.
