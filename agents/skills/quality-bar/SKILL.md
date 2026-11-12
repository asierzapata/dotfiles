---
name: quality-bar
description: What Asier cares about when a change is designed, built, tested, and reviewed, and what he finds useful to be shown along the way. Covers state and state transitions, the contracts and coupling at the boundaries between layers, boundaries that move, tests that prove behaviour through integration, and the questions a diff does not answer. Use when planning, designing, implementing, or reviewing a feature, a refactor, or a stack of PRs, when a change adds or moves state, runs concurrently, durably, or on retry, or crosses more than one layer or module, and when writing or reviewing tests. Skip it for a change with one obvious shape, such as a rename, a copy change, a config value, or a one-line fix.
---

# What Asier cares about in a change

This is not a process. It describes what Asier looks at and why, so that you can apply it with judgment at whatever point of the work you are in: planning, coding, writing tests, or reviewing. Use the parts that fit the change and scale them to its risk. A small change may need two sentences from here, and a durable workflow may need all of it.

The reason it exists: the defects his teammates caught in review were almost never in the lines of the diff. They were two callers interleaving, a failure being replayed, a layer patched for a responsibility it did not own, and tests that passed without proving what they named. Reading code harder does not find those. Thinking about state, boundaries, and test cases does, so that is where he wants both his attention and yours.

Use the project's own skills for how things are done there, such as its architecture check, its review, and its PR skill. This skill is about what deserves attention.

## State and transitions come first

Before the code, he wants to know what state a change adds or changes, where it is stored, and which single component is allowed to write it. State with two writers is where most of the hard bugs start.

Then the transitions. For each one, what triggers it, and what happens in three situations: it runs twice, it runs concurrently with another, and it stops halfway. A transition without an answer for those three is not designed yet, and it is better to say "I do not know what happens here" than to leave it unsaid. In durable, retried, or event-driven code these three are the normal case, not the edge case.

## Boundaries

Most of his design decisions are about the boundaries between distinct parts of the system, such as a helper that turns events into actions, the dispatcher below it, and the work queue below that. Three things matter at each boundary a change touches.

**The contract, in both directions.** What a layer accepts is as important as what it returns.

- *Accepts:* the inputs and options it takes, which combinations are valid, what it does with an invalid one (rejects, ignores, or silently changes behaviour), and in which of its own states it accepts the call at all.
- *Returns:* the result, the errors, the side effects, and what the caller may rely on afterwards, such as "stored", "will run once", or "ran".

**The coupling line.** What the caller has to know about the layer below for the call to be correct is the coupling, and the line is where that knowledge stops. Know where it sits today. When every caller has to carry the same rule, the line is too high.

**Moves.** When a change moves a boundary, say so out loud, as its own statement and not folded into the description of the change: "This moves *responsibility* from *A* to *B*". Add what A stops knowing, what B now has to guarantee, and which other callers of B get the new behaviour without asking for it. If nothing moves, saying "no boundary moves" is useful too. A moved boundary is an architectural decision and it is his to make consciously, so it should never arrive as a side effect of an implementation detail. Boundaries move by accident during implementation more often than by plan. When you notice the code starting to do it, such as a caller handling something the layer below owns, raise it then.

### Patch or design

He redid a whole stack of PRs because idempotency was added in the event-to-action helper when it belonged to the dispatcher and the work queue below it. The first version worked, and it was a patch.

A change is a patch when it handles a responsibility in a layer that does not own the state behind it, when a caller has to know how the layer below works, or when the same rule would have to be repeated in a second caller. Moving the coupling line down, so the owning layer carries the rule, is usually the design. When you see a patch, show him the design alternative and what it costs, even when it is larger, and let him choose. Do not pick the small version for him, and do not pick the large one either. For a stack of PRs, this is worth settling for the whole stack before the first PR exists.

## Tests

He has tended to gloss over tests and wants to stop. What helps him is seeing tests as cases, not as code.

**Cases come from the design.** One per transition, the twice, concurrent, and halfway cases of the transitions that can meet them, and both sides of each contract: what a layer promises to return, and what it does with each input it should not accept. Agreeing the cases before the code is written is cheap and catches design gaps early, so offer the list when the change is risky enough to deserve it.

**Integration first.** A case should enter through the public entry point, such as the endpoint, command, query, or event, and run against the real store and the real layers below. Replace only what leaves the system. A unit test is right for pure logic with many input combinations. A test that stubs the layer under suspicion proves nothing about it.

**A test must prove what it names.** For every case, be able to name the bug that would make it fail. Watch for a test whose input does not match its title, an assertion the setup already guarantees, a stub that returns the answer being asserted, and table rows where one field is only used for the name.

**Breaking the code is the only real evidence.** For the cases that guard a transition or a contract, introduce the bug, run the test, confirm it fails, and restore the code. Tell him which tests still passed.

When he reviews tests, a table serves him better than the test file: the case, what it enters through, what is real, what is replaced, the bug it would catch, and the file and line. Fill it from what the test really does, not from its title. List what is not tested and why, so a gap is his decision and not an omission. A reviewer that did not write the tests fills this table more honestly than the author, so use a fresh subagent for it when the change matters.

## What the diff does not show

These five questions cover most of what reached review. Have answers from the code before calling a change done, and say plainly when there is none.

1. What happens with two concurrent callers?
2. What happens when it fails halfway and runs again?
3. What happens to work in flight if this is reverted after deploy?
4. Who else calls or renders what changed?
5. What data now reaches a place it did not reach before?

When he wants to check his own understanding of a change, ask him these and let him answer before you do. Do not turn it into a ritual on every change.

Also say whether the change was run where it will really run, such as a browser for UI, or a production-like load for anything that changes what is loaded at startup. "Tests pass" and "it works in the real environment" are different claims.

## Fresh eyes

The agent that designed or wrote something shares its own blind spots, and after a long session so does he. A reviewer that starts with no memory of the conversation does not, which is why a design that only makes sense with the conversation behind it fails in front of one. Use a fresh subagent for this, given only the written design and the files it references, never a summary of what was discussed and never your own conclusions. A review done in the same context is not this review. Use it when the change is risky enough to deserve it, not on every change.

- **Comprehension check.** Ask the fresh reviewer to say back, from the document alone, what the change does: the state, the transitions, and who owns what. Show him that paraphrase next to the intent. Where the two differ, the design is unclear or wrong on paper, and he can see it in a minute without reading the whole design again.
- **Design review through his lenses.** Ask the fresh reviewer for what this skill cares about, not for general feedback: a transition with no answer for twice, concurrent, or halfway, a contract that says what it returns but not what it accepts, a caller that has to know how the layer below works, and a boundary that moves without being stated.
- **Drift check after implementation.** Have a fresh reviewer compare the agreed design with the code that was written, and report where they differ. This is the direct way to find a boundary that moved by accident, or a transition that was implemented differently from what he accepted.

A fresh reviewer produces a lot of findings, and passing them all on would cost him the attention this is meant to save. Triage them first: for each one, either propose the fix or say why you contest it, and bring him only the ones that change a decision. Re-check once after fixing. What is still open after that is a trade-off to state, not a reason for another round.

## How to show him things

- **Bottom line first.** Open with what he has to decide right now and what is blocked until he does, before any explanation. Put each decision as a question he can answer in a few words, with your recommendation and the one reason behind it. If nothing needs a decision, say that first, so he knows the rest is for reading and not for answering. Then give the supporting detail below, in order of how much it matters to those decisions, and after that the things he may want to comment on but that do not block anything. He should be able to stop reading after the first block and still unblock you.
- **Short.** He is trying to protect his attention. Anything long gets skimmed, which is the failure this skill exists to prevent. Select what matters instead of covering everything.
- **Pictures for structure.** State machines, boundaries, and where the coupling line sits are diagrams, with the `diagram` skill.
- **Decisions named as decisions.** A boundary move, a patch chosen over a design, and an untested gap are his calls. Each one belongs in that opening block as its own choice, never inside the detail below it, so that agreeing with the whole does not silently approve it.
- **Unknowns stated.** "I did not check this" is more useful to him than a confident summary.
