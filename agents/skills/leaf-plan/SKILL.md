---
name: leaf-plan
description: Hand a written plan, spec or design to Asier for review in leaf before acting on it. He notes blocks of it and sends a verdict, which arrives as your next message. Use after writing a plan that needs his sign-off, or when he asks to review your plan in leaf.
---

# leaf-plan: get a plan reviewed

In Claude Code, plan mode already does this: a hook sends the plan to leaf when you leave plan mode, and his verdict comes back as the answer. Use this skill for a plan you write outside plan mode, or in another agent.

1. Write the plan to a Markdown file. Put it in your scratchpad or a temporary folder unless he asks for it in the repository, such as `docs/plans/<topic>.md`. Use headings for phases and list items for steps. Each heading and everything under it, up to the next heading, becomes one block. He can comment on a whole block, a single line or a range of lines, so keep each section to one phase and each line to one step. Don't also paste the plan into chat.
2. Run:

   ```sh
   leaf plan <file>
   ```

   Inside Rex, this opens the review beside your pane and returns at once with `Opened … for review`.
3. **End your turn.** Don't wait, sleep, poll or read the pane. The review arrives as your next message.

If leaf says there's nowhere to open it (you're not in Rex, tmux or Herdr), tell him to run `leaf plan <file>` in his terminal and paste you the review. In a script that has to block, `leaf plan --wait <file>` prints the review to stdout when he sends it.

## The review you get back

```markdown
# Review of docs/plans/auth.md: changes requested

Changes requested. Revise, then submit again.

Global: Split the migration into its own step.

## 1. Block 4, "Phase 2 > Tokens" (lines 12-18): comment
> Rotate the token on every privilege change

That logs people out mid-session.

## 2. Block 6 (lines 30-41): remove
...
```

A note with `(lines …)` after the heading is on the whole block. One with `, line N` or `, lines N-M` is on just those lines, quoted below it. A `Global:` note is on the whole plan: address it as well as the numbered items. Line numbers refer to the file as you submitted it.

The kinds of note:

- **comment**: do what it says. If it's a question or a remark with nothing to change, answer it.
- **remove**: take that block or passage out.
- **replace**: use the quoted text instead.

The verdict:

- **approved**: carry on with the plan as written.
- **approved with notes**: carry on, and apply every numbered item as you go.
- **changes requested**: revise the same file, addressing every numbered item, then run `leaf plan` on it again. His notes on blocks you didn't change are kept.

If the message says the review was closed without a verdict, ask him how he'd like to go on.

If what you find while carrying out an approved plan changes it, such as a step that can't work as written, say so and what you did instead, rather than following the plan to the letter.
