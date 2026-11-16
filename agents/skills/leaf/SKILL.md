---
name: leaf
description: Use leaf, Asier's terminal reader and reviewer, to show him documents, diffs and pull requests and to read the comments he leaves. Use when Asier mentions leaf, or asks to read or show a PDF, EPUB, Markdown file, article, diff or pull request in the terminal. For his review of a change use human-review, and for his sign-off on a plan use leaf-plan.
---

# leaf

leaf reads PDFs, EPUBs, Markdown files, images and web articles in the terminal, and shows diffs and GitHub pull requests. Asier reads in leaf. You start it, hand it files, and read what he leaves behind.

## Putting something in front of him

leaf is a full-screen terminal app. Your shell tool has no terminal, so a bare `leaf open …` or `leaf diff` run by you exits at once or shows nothing. There are three ways to show him something:

1. **Reviews.** `leaf review` (the `human-review` skill) and `leaf plan` (the `leaf-plan` skill) open in a pane beside yours, and his verdict comes back as your next message.
2. **Anything else, in Rex.** Open it in a pane beside yours: `rex split --split=right -- leaf open notes.md`.
3. **Outside Rex.** Tell him the exact command to run, for example `leaf diff --branch`.

`leaf version` prints the installed version, and `leaf --help` prints every command.

## Commands

| Command | What it opens |
|---|---|
| `leaf open <file or url>`, or `leaf <file>` | A PDF, EPUB, Markdown file, image or web article. It reopens where he left off. |
| `leaf diff` | Unstaged changes, to browse without sending a review. `--staged`, `--branch`, `--base <ref>`, a range such as `main...HEAD`, a path, a `.patch` file, or a GitHub PR, commit or compare link. `--inline` uses one column. |
| `leaf pr` | His open pull requests and issues. `leaf pr 12`, `leaf pr owner/repo#12` or a link opens one, with Summary, Timeline, Comments, Code and Checks tabs. |
| `leaf review [source]` | His review of a change. See `human-review`. |
| `leaf plan <plan.md>` | His review of a plan. See `leaf-plan`. |
| `leaf comments --json` | Every saved diff comment as JSON: key, file, side, line range, body, and state (`draft`, `agent`, `github`). |

## Reading what he left

- Diff comments: `leaf comments --json`. A comment in state `draft` hasn't been sent to anyone yet.
- In the reader he can select text and press `@`, and in a diff press `C` and then `ctrl+enter`. Either way the question is pasted into your pane with the file, the line numbers and the text around it. Treat it as his message.

## Keys, so you can tell him what to press

- **Reader:** `j/k` scroll, `space/b` a screen, `←/→` page, `t` go to page, `f` find. `@` asks you about the selection, `y` highlights it. `m` bookmarks, `?` lists every key, `q` quits.
- **Diff:** `j/k` move, `[`/`]` files, `tab` overview. `V` selects lines, `c` comments, `F` notes the file, `M` adds a global note. `S` sends everything as one review. `i` switches split and inline.
- **Pull request:** `tab` or `1`–`5` switch tabs. `m` merges, `a` approves, `c` comments, `o` opens it on GitHub.

## Things to know

- Reading positions, highlights, comments and unsent review notes live in SQLite at `~/.local/share/leaf/leaf.db`. Never write into it by hand.
- leaf finds your pane through `REX_BLOCK`. `LEAF_AGENT_PANE` overrides which pane questions go to.
- Read aloud (`a`) sends the document's text to Microsoft's text-to-speech service. Don't suggest it for anything sensitive.
