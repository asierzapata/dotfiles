---
description: Lint a piece of prose against the shared writing style guide, flagging AI-sounding cadence and stylistic issues with concrete rewrites.
---

# Lint Prose

You are reviewing a piece of prose against the rules in `~/.claude/writing-style.md`. The goal is to catch AI-sounding cadence and other style violations, then propose concrete rewrites the author can accept or reject.

## Workflow

1. **Read the style guide.** Open `~/.claude/writing-style.md` first. The "Avoid AI-Sounding Cadence" and "Voice and Tone" sections are the most load-bearing for this command.

2. **Identify the target prose.**
   - If the user passed text as an argument or pasted it inline, lint that.
   - If the user pointed at a file, read the file. If they pointed at a range, focus on that range.
   - If neither is clear, ask once which text to lint.

3. **Scan for violations.** For each issue, capture:
   - The exact offending sentence or phrase (quoted).
   - Which rule it breaks (named, e.g. "Rhythmic antithesis with dropped verbs").
   - Why it reads as AI or as bad style in this specific case.
   - A concrete rewrite. Not "consider rephrasing" — actual replacement text.

   Prioritize: AI-cadence tells first (they're the highest-signal), then voice/tone, then formatting (em-dashes as asides, passive voice, etc.). Skip nits if the prose is already strong.

4. **Report.** Use this shape:

   ```
   ## Issues found

   ### 1. <Rule name>
   **Original:** "<exact quote>"
   **Why:** <one-line diagnosis>
   **Rewrite:** "<concrete replacement>"

   ### 2. ...
   ```

   If the prose is clean, say so in one sentence. Don't invent issues.

5. **Offer to apply.** If the target was a file and there are accepted rewrites, ask whether to apply them. Don't edit files without confirmation.

## Rules of engagement

- **Quote exactly.** Don't paraphrase the original when flagging — the author needs to find it.
- **One rewrite per issue.** Picking the best fix is the whole job. Don't offer three options.
- **Don't lecture.** The diagnosis is one line. The author can read the rule in the style guide if they want more.
- **Respect intent.** If a sentence is short and punchy on purpose (a section opener, a callout), don't flag it as "uniform short sentences" unless it's part of a run.
- **Skip code blocks, file paths, type signatures, and direct quotes from other sources.** Lint prose, not literals.
- **Don't moralize about AI use.** The author already knows. Just fix the prose.
