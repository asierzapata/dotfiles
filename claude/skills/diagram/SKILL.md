---
name: diagram
description: Show Asier a Mermaid diagram in a Rex pane beside the conversation with `mermaid-view`. Asier understands systems much better with visuals than with text, so use this proactively, without being asked, whenever you explain an architecture, a flow between components, a sequence of calls, a state machine, a data model, or how a change moves through a system, and whenever you would otherwise draw boxes and arrows in text. Also use it when Asier asks to see, draw, diagram, or visualize something.
---

# Diagrams in a Rex pane

`mermaid-view` renders Mermaid with beautiful-mermaid and shows it in a "Diagram" pane to the right of your own pane in the current Rex session. Each call redraws the same pane, so iterate on one diagram instead of opening new ones. Run `mermaid-view --help` for every option.

## Show a diagram

Write the Mermaid source to a file in your scratchpad, named after the topic, then show it:

```sh
mermaid-view <scratchpad>/markers-flow.mmd --title "Markers flow"
```

- The pane shows box-drawn Unicode text by default. When the diagram is wider than the pane, it switches to an image on its own.
- Pass `--image` when the diagram is dense, has long labels, or Asier asks for the nicer version. It renders through headless Chrome and takes a second or two.
- Keep the default theme unless Asier asks for another one. `mermaid-view themes` lists them.
- Outside Rex (`REX_SESSION` unset), the command prints the diagram to stdout instead. Then say that no pane was opened.

## Write diagrams that render

Only these types are supported: `graph`/`flowchart` (TD, LR, BT, RL), `sequenceDiagram`, `stateDiagram-v2`, `classDiagram`, `erDiagram`, and `xychart-beta`. Gantt, pie, mindmap, and timeline fail with "Invalid mermaid header". Pick another type, or skip the diagram.

The parser silently drops lines it cannot read, so a diagram can render with missing nodes or edges and no error. After each call, check what was drawn: in text mode, read the pane with `rex capture -s "$REX_SESSION" -b <pane id from the output> --trim`. In image mode, render a copy with `mermaid-view render <file> --format png -o <scratchpad>/check.png` and read the PNG. If anything is missing, fix the source before talking about the diagram.

Keep diagrams small enough to read in a side pane: about 12 nodes or 8 participants. Split a bigger system into an overview and a zoomed-in diagram, and show them one at a time. Use the names from the code for nodes and participants, and short verbs for edges.

## Talk about it

Say in one sentence what the pane shows, then explain by referring to its parts ("the dashed return to Handler is the end of the run"). Don't repeat the whole diagram in prose. When Asier asks a follow-up, update the diagram if the answer changes the picture.

Close the pane with `mermaid-view close` only when Asier asks.
