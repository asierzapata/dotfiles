## Rex

When running inside Rex (`REX_SESSION` is set), start long-running or non-terminating
commands in a new Rex tab instead of your own shell tool, so I can watch them. This includes
dev servers and watchers (`npm run dev`, `npm start`, Edpuzzle's `npm run client`,
`npm run server`, `npm run server:localhost`, `vite`, `docker compose up`, `tail -f`, etc.):

```sh
rex window new -s "$REX_SESSION" <TabName> -c <project_dir> --keep-open --focus=false --json -- <command>
```

- Use a descriptive tab name (Server, Client, Dev, Logs).
- Save `.block_ids[0]` and check startup with `rex capture -s "$REX_SESSION" -b <block> --trim | tail -n 50`.
- Before opening a new tab, check `rex window ls -s "$REX_SESSION" --json` for one already running the same command; reuse or restart it instead of duplicating.

## Leaf

leaf is my terminal reader and reviewer. The `leaf`, `leaf-plan` and `human-review` skills
cover how to drive it; this is when to reach for it.

- Plans: when you write a plan, spec or design that needs my sign-off, hand it to me with
  `leaf plan <file>` (the `leaf-plan` skill) instead of pasting it into chat. In Claude
  Code, plan mode already routes `ExitPlanMode` through leaf with a hook.
- Reading: to show me a PDF, EPUB, Markdown file, article, diff or pull request, open it
  with leaf in a Rex pane beside yours (`rex split --split=right -- leaf open <file>`).
  Never run a bare `leaf` command in your own shell; it needs a terminal.
- Code review: when I want to review a change myself, use the `human-review` skill, which
  opens it with `leaf review`. Do this when I ask, or when you finish a change and I asked
  you to hand it to me for review. Don't open one unprompted after every change.
- Questions I send from leaf (selected lines with `@`) arrive pasted into your pane with
  the file and line numbers. Treat them as my message.

## Diagrams

I understand systems much better from pictures than from text. When you explain how
something works, such as an architecture, a flow between components, a sequence of calls,
a state machine, or a data model, use the `diagram` skill to show a Mermaid diagram in a
Rex pane with `mermaid-view`. Do this without being asked, and instead of drawing boxes
and arrows in text. Skip it for answers that a diagram wouldn't make clearer.
