## Rex

When running inside Rex (`REX_SESSION` is set), start long-running or non-terminating
commands in a new Rex tab instead of the Bash tool, so I can watch them. This includes
dev servers and watchers (`npm run dev`, `npm start`, Edpuzzle's `npm run client`,
`npm run server`, `npm run server:localhost`, `vite`, `docker compose up`, `tail -f`, etc.):

```sh
rex window new -s "$REX_SESSION" <TabName> -c <project_dir> --keep-open --focus=false --json -- <command>
```

- Use a descriptive tab name (Server, Client, Dev, Logs).
- Save `.block_ids[0]` and check startup with `rex capture -s "$REX_SESSION" -b <block> --trim | tail -n 50`.
- Before opening a new tab, check `rex window ls -s "$REX_SESSION" --json` for one already running the same command; reuse or restart it instead of duplicating.

## Diagrams

I understand systems much better from pictures than from text. When you explain how
something works, such as an architecture, a flow between components, a sequence of calls,
a state machine, or a data model, use the `diagram` skill to show a Mermaid diagram in a
Rex pane with `mermaid-view`. Do this without being asked, and instead of drawing boxes
and arrows in text. Skip it for answers that a diagram wouldn't make clearer.
