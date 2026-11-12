---
name: diagram
description: Show Asier a Mermaid diagram in a Rex pane beside the conversation with `mermaid-view`. Asier understands systems much better with visuals than with text, so use this proactively, without being asked, whenever you explain an architecture, a flow between components, a sequence of calls, a state machine, a data model, or how a change moves through a system, and whenever you would otherwise draw boxes and arrows in text. Also use it when Asier asks to see, draw, diagram, or visualize something.
---

# Diagrams in a Rex pane

`mermaid-view` renders Mermaid with beautiful-mermaid and shows it in a "Diagram" pane to the right of your own pane in the current Rex session. Each call redraws the same pane, so iterate on one diagram instead of opening new ones. Run `mermaid-view --help` for every option.

## Show a diagram

Write the Mermaid source to a file in a temporary directory (your scratchpad, if your tool gives you one), named after the topic, then show it:

```sh
mermaid-view <tmp>/markers-flow.mmd --title "Markers flow"
```

- The pane shows box-drawn Unicode text by default. When the diagram is wider than the pane, it switches to an image on its own.
- Pass `--image` for any diagram with a branch, a merge, an edge label, or a subgraph. Text mode draws those with detached labels and lines that run into the boxes, so keep it for a straight chain and for sequence diagrams. The image renders through headless Chrome and takes a second or two.
- Keep the default theme unless Asier asks for another one. `mermaid-view themes` lists them.
- Outside Rex (`REX_SESSION` unset), the command prints the diagram to stdout instead. Then say that no pane was opened.

## Write diagrams that render

Only these types are supported: `graph`/`flowchart` (TD, LR, BT, RL), `sequenceDiagram`, `stateDiagram-v2`, `classDiagram`, `erDiagram`, and `xychart-beta`. Gantt, pie, mindmap, and timeline fail with "Invalid mermaid header". Pick another type, or skip the diagram.

The parser silently drops lines it cannot read, so a diagram can render with missing nodes or edges and no error. After each call, check what was drawn: in text mode, read the pane with `rex capture -s "$REX_SESSION" -b <pane id from the output> --trim`. In image mode, render a copy with `mermaid-view render <file> --format png -o <tmp>/check.png` and look at the PNG if you can read images. If anything is missing, fix the source before talking about the diagram.


## Lay it out so it reads

A diagram can hold every fact and still be unreadable. That has been the usual failure here: the content was right, and the picture had lines wrapping around the whole diagram, labels on top of each other, and shapes so large that the pane shrank everything else. Mermaid chooses the positions, so the layout is decided by how you write the source. These rules come from re-rendering diagrams that failed.

**One question per diagram.** Decide the one thing the picture must make obvious, such as who writes the state, or what happens after a failure, and leave out what does not serve it. A diagram that shows the normal path, the failure path, and the retry path together is three diagrams. Draw the main one, and offer the others.

**Check that a diagram is the right form.** A set of independent cases, such as "result A leads to X, result B leads to Y", is a table, and it reads better as a table in your answer. Draw a flowchart when the order or the merging of paths is the point.

**Everything flows one way.** Put whoever starts the action first in the flow direction and write every edge from the earlier node to the later one. An edge that points against the flow is drawn as a line around the outside of the whole diagram. If the caller sits in the last box and calls into the first one, reorder the boxes, do not draw the arrow backwards. A real loop back is fine when it is the only one.

**Make the main path visible.** Use `==>` for the path he should follow first and `-->` for the rest, and `-.->` for what is exceptional or out of band. Colour at most one or two nodes that the diagram is about, with a class:

```
classDef hot fill:#7a2e2e,stroke:#ff6b6b,color:#fff
class JM hot
```

When every node and line has the same weight, he has to read all of it to find the point.

**Keep labels short.** A node label is a name, at most three or four words on one line. An edge label is one to three words, because each one is drawn as a box on the line and long ones overlap their neighbours. Do not put explanations, lists of methods, or `<br/>` paragraphs in a label. Say those in the text next to the diagram. Keep a subgraph title shorter than the widest node inside it, or it spills out of its box.

**Write decisions as hexagons.** `G{{parent terminal?}}` stays the size of its text. A diamond `G{...}` is drawn several times larger than a normal node and pushes the rest of the diagram off the pane.

**Declare every node with its label before the edges,** in the order they should appear along the flow, and then list the edges. A node that is first mentioned bare inside an edge keeps its id as its label, and the declaration order is what places the nodes. Put the main path's edges first.

**Keep exits next to their decision.** An early exit such as "yes, stop" should be the next node after the decision, not a box at the far end with a line running the length of the diagram.

**Limit how much meets at one node.** More than three edges entering or leaving a node turns into a bundle of parallel lines. Merge the edges that mean the same thing for this diagram's question, such as two different ways of ending up dropped.

**Choose the direction for the pane.** The pane is tall and narrow. Use `TD` for a chain of more than four or five steps, and `LR` for a few stages with fan-out, and for state diagrams (`direction LR` on the first line), which read as a timeline. If the rendered image is much wider than tall, switch to `TD` or cut nodes.

**Stay small.** About 10 nodes, 12 edges, and 2 decisions, or 6 participants. Count the edges, not only the nodes: crossing lines are what makes a diagram hard, and they come from edges. Split a bigger system into an overview and a zoomed-in diagram, and show them one at a time. Use the names from the code for nodes and participants.

### Look at it before he does

Render the PNG and look at it, every time, with `mermaid-view render <file> --format png -o <tmp>/check.png`. Checking that nothing is missing is not enough. Redraw before showing it when you see any of these:

- a line that travels around the outside of the diagram, or along its whole length
- labels that touch or overlap, or a title outside its box
- one shape much larger than the nodes around it
- lines crossing where reordering the declarations would avoid it
- no visible main path, so the eye has nowhere to start
- an image far wider or taller than the pane can show at a readable size

Two attempts at fixing the layout is the limit. If it is still tangled, the diagram is trying to show too much, so cut it or split it.

## Talk about it

Say in one sentence what the pane shows, then explain by referring to its parts ("the dashed return to Handler is the end of the run"). Don't repeat the whole diagram in prose. When Asier asks a follow-up, update the diagram if the answer changes the picture.

Close the pane with `mermaid-view close` only when Asier asks.
