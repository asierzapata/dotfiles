---
name: quality-bar
description: What Asier cares about when a change is designed, built, tested, and reviewed, and what he finds useful to be shown along the way. Covers how to approach the work (restating the goal, first principles, design before code, the experience of whoever uses the work, subtraction, code that is easy to trace, a consistent vocabulary, blast radius, verifiable units, evidence behind every claim and number, root causes), state and state transitions, the contracts and coupling at the boundaries between layers, boundaries that move, tests that prove behaviour through integration, and the questions a diff does not answer. Use when planning, designing, implementing, or reviewing a feature, a refactor, or a stack of PRs, when a change adds or moves state, runs concurrently, durably, or on retry, or crosses more than one layer or module, and when writing or reviewing tests. Skip it for a change with one obvious shape, such as a rename, a copy change, a config value, or a one-line fix.
---

# My quality bar

This is not a process. It describes what I look at and why, so that you can apply it with judgment at whatever point of the work you are in: planning, coding, writing tests, or reviewing. Use the parts that fit the change and scale them to its risk. A small change may need two sentences from here, and a durable workflow may need all of it.

## How I want the work approached

When the decisions and the communication along the way are right, the code and the tests usually follow. So this is where I want the most care.

**Restate the goal first.** Before starting anything that is not trivial, say back in a sentence or two what I am trying to achieve and the smallest change that gets there. When I explain a new concept, restate that concept, not the nearest existing mechanism it resembles.

**Start from the problem, not from what exists.** Ask what you would build if this requirement had been there from the start. An existing design, prototype, convention, or earlier answer is input to weigh, not the frame to fit into. When I propose something, critique it honestly. Agreeing is not the job. When two fixes built on the same assumption have failed, write the assumption down and test it before trying a third.

**Agree the shape before writing code.** For anything with a design, that means the data, which component owns each piece of state, and the boundaries, before the first file. Sketch at least two shapes and recommend the one where callers need to know least. When the decision has no precedent in the codebase, or depends on how the thing feels to use, sketches are not enough: build two or three throwaway prototypes and compare them side by side. Once the design is agreed and I hand over the execution, proceed without asking at every step.

**The experience is the target.** When what is convenient to build conflicts with what is good to use, choose what is good to use. The user is whoever consumes the work: the person in front of a screen, the colleague who calls an API, and the engineer who maintains the code next. Fewer things done well beat more things done roughly, and the details count: error states, feedback, transitions, spacing. Explain the impact of a choice from that person's side, not from the implementation's.

**Subtract before you add.** Build for how the thing is used today. A new flag, mode, option, or piece of infrastructure needs a real need behind it, and "we add it later if this decision bites us" is usually the right answer. Before an addition, a refactor, or a rewrite, remove the dead weight first and build on the simpler base. When a design keeps growing mechanisms to handle its own cases, step back and look for the simpler model, often by moving the decision to one place: make a choice once, behind one source of truth, and pass the result on, instead of repeating it in several places. This is not the same as choosing the smaller diff: I will take a larger change that puts a rule in the layer that owns it over a small patch. Among the changes that put the rule where it belongs, pick the smallest. The goal is the fewest moving parts, not the fewest lines.

**Keep it easy to trace.** Code is hard to read for two separate reasons: the layers between a question and its answer, and the hidden state the reader has to hold in their head. Inline the layers that only forward, such as a wrapper with one caller, an adapter with a single implementation, or a pass-through method. Keep state in the smallest scope that works, prefer a return value to a mutation, and derive a value instead of keeping two copies in sync. The test: can a new reader quickly answer "where does X come from?" and "what can change X?" If not, cut layers or cut state.

**One name per concept.** Use the vocabulary the codebase and the team already have. A new term, or a new meaning for an existing one, is my decision, so propose it as one and check that it does not collide with a word already in use. Define every term the first time you use it, including the ones coined during the session.

**Match the speed to the blast radius.** Before deciding how careful to be, ask who is affected if this is wrong and how easily it is undone. An API other people build on, data migrations, shared environments, and anything outward facing go slowly and with proof. Internal code that few people touch and that can be reverted goes fast, without shims or staging. For a risky change, find the one fact it is safe because of and prove that fact, rather than listing everything that might go wrong. The test: if this turns out to be wrong after it ships, who notices, and what does it take to undo it? If the answer is "only me, and a revert", move fast. If it is anyone else, or something a revert does not undo, slow down.

**Aim for the end state.** In a planned rewrite or migration, converge on the target design instead of keeping every intermediate step comfortable. Compatibility code written only to smooth the transition tends to stay. An intermediate step may be broken when that is planned, scoped, and reversible: say where, keep the checks running for the areas being touched, and verify everything at the end. The blast radius still decides how much of this is acceptable.

**Work in units that can be checked.** Split multi-step work, such as a migration, a sweep of similar edits, or a stack of PRs, into small units that each end in a state that can be verified, and do not start the next one until the current one is green. Order them so the sequence proves itself: the failing test before the fix, the removal before the reshape, the baseline before the change. Each commit and each PR should stand on its own.

**Build the tool, not the edits.** When the work is not trivial, such as a migration, a sweep, an analysis, or a check, write the smallest script, codemod, or generator that does it or proves it, instead of doing it by hand. Do the first case by hand, then build the tool and prove it by running it on that case. Make it safe to run again. The tool is what I can rerun to trust the result, so show it to me. Skip it for a couple of obvious edits.

**Say how you know.** Every claim rests on some evidence, and I need to see which. From weakest to strongest: you said so, you pointed at the line, you showed the bad case cannot happen, you ran it, you reproduced it in the running app. State each claim at the level you reached, and mark anything at the first two levels as not verified. In practice: check against the current main branch, not a stale one. Look documentation up instead of answering from memory. Verify a review comment against the code before calling it a bug, and search before saying something does not exist. The test: for each claim in a message, could you paste the command output, the line, or the link that backs it? If not, it is a guess, and it should be marked as one.

**Explain a number before trusting it.** This applies to a speedup, a regression, a latency, a count, or an eval result. Use the real metric, not a sampled or approximated source. Before measuring, write down the decision the number informs and the result that would change it. Before reporting it, name what limits it, from a profile or counters taken during a run and not from reading the code. Then rule out that it measured something else: errors, cached or skipped work, code that never ran, or noise. Give the number with its run count and its spread. When the spread between runs is larger than the effect, there is no result.

**Fix the cause, not the symptom.** Confirm the cause before proposing a fix. Ask whether the state that triggered the symptom should exist at all. If it should not, a guard where it surfaced hides the bug, and the fix belongs where that state was produced. "Bad luck" is not a cause until a second example rules out a pattern. When the cause is drift between environments, the drift is what to fix.

**Turn repeated corrections into structure.** When the same correction comes up a second time, propose the lint rule, check, script, or skill change that makes it unnecessary, instead of another instruction to remember.

## State and transitions come first

Before the code, I want to know what state a change adds or changes, where it is stored, and which single component is allowed to write it. State with two writers is where most of the hard bugs start.

When two actors might write the same thing, first ask whether they need to share it at all. Usually each one can write its own record, and the merge happens where the state is read. Only when one shared target is a real requirement, serialize access with structure, such as a single writer, a lock, or compare-and-swap, and never with a convention people have to remember.

Then the transitions. For each one, what triggers it, and what happens in three situations: it runs twice, it runs concurrently with another, and it stops halfway. A transition without an answer for those three is not designed yet, and it is better to say "I do not know what happens here" than to leave it unsaid. In durable, retried, or event-driven code these three are the normal case, not the edge case.

The answer I expect for "twice" and "halfway" is that the transition reaches the correct state however many times it runs and wherever the previous run stopped. Derive each step from the state that exists, not from what the previous run meant to do: read the current state, compare it with the goal, and apply only the difference. Whatever a run can leave behind, such as a lock, a claimed job, or a half-written record, must be recognizable as stale by the next run. If the outcome depends on what was left behind, a reconciliation step is missing.

**Model the domain on purpose.** Put the rules of the domain in a structure, in the way the platform and the codebase at hand already do it. Where there is an established way to model, use it. Where there is none, that is not a reason to skip the modelling: a state machine instead of booleans that must stay in sync, a typed model instead of loose parameters, a table or a map instead of branching spread across files. Do not force it either. Boring code is fine when the shape is clear, local, and unlikely to grow. The sign that it was skipped is a feature that adds one more branch to an if/else chain, or a second boolean that has to agree with the first.

## Boundaries

Most of my design decisions are about the boundaries between distinct parts of the system. Four things matter at each boundary a change touches.

**The contract, in both directions.** What a layer accepts is as important as what it returns.

- *Accepts:* the inputs and options it takes, which combinations are valid, what it does with an invalid one (rejects, ignores, or silently changes behaviour), and in which of its own states it accepts the call at all.
- *Returns:* the result, the errors, the side effects, and what the caller may rely on afterwards, such as "stored", "will run once", or "ran".

**The coupling line.** What the caller has to know about the layer below for the call to be correct is the coupling, and the line is where that knowledge stops. Know where it sits today. When every caller has to carry the same rule, the line is too high.

**Where the checks live.** Validate and handle errors where data enters the system: a request, a config file, an external API, a message. Convert raw data into domain types there, and inside trust those types without checking again. Keep framework and transport types out of the domain, and keep business rules in code that does not depend on the framework. A check on data that is not crossing a boundary is either redundant or hiding a bug upstream.

**Moves.** When a change moves a boundary, say so out loud, as its own statement and not folded into the description of the change: "This moves *responsibility* from *A* to *B*". Add what A stops knowing, what B now has to guarantee, and which other callers of B get the new behaviour without asking for it. If nothing moves, saying "no boundary moves" is useful too. A moved boundary is an architectural decision and it is mine to make consciously, so it should never arrive as a side effect of an implementation detail. When you notice the code starting to do it, such as a caller handling something the layer below owns, raise it then.

### Patch or design

A change is a patch when it handles a responsibility in a layer that does not own the state behind it, when a caller has to know how the layer below works, or when the same rule would have to be repeated in a second caller. Moving the coupling line down, so the owning layer carries the rule, is usually the design. When you see a patch, show me the design alternative and what it costs, even when it is larger, and let me choose. Do not pick the small version for me, and do not pick the large one either. For a stack of PRs, this is worth settling for the whole stack before the first PR exists.

## Tests

What helps me is seeing tests as cases, not as code.

**Cases come from the design.** One per transition, the twice, concurrent, and halfway cases of the transitions that can meet them, and both sides of each contract: what a layer promises to return, and what it does with each input it should not accept. Agreeing the cases before the code is written is cheap and catches design gaps early, so offer the list when the change is risky enough to deserve it.

**Integration first.** A case should enter through the public entry point, such as the endpoint, command, query, or event, and run against the real store and the real layers below. Replace only what leaves the system. A unit test is right for pure logic with many input combinations. A test that stubs the layer under suspicion proves nothing about it.

**Test what the code owns.** Do not test the behaviour of the framework or library underneath, and do not keep an old test only because it exists.

**A test must prove what it names.** For every case, be able to name the bug that would make it fail. Watch for a test whose input does not match its title, an assertion the setup already guarantees, a stub that returns the answer being asserted, and table rows where one field is only used for the name.

**Breaking the code is the only real evidence.** For the cases that guard a transition or a contract, introduce the bug, run the test, confirm it fails, and restore the code. Tell me which tests still passed.

When I review tests, a table serves me better than the test file: the case, what it enters through, what is real, what is replaced, the bug it would catch, and the file and line. Fill it from what the test really does, not from its title. List what is not tested and why, so a gap is my decision and not an omission. A reviewer that did not write the tests fills this table more honestly than the author, so use a fresh subagent for it when the change matters.

## What the diff does not show

Have answers to these five questions from the code before calling a change done, and say plainly when there is none.

1. What happens with two concurrent callers?
2. What happens when it fails halfway and runs again?
3. What happens to work in flight if this is reverted after deploy?
4. Who else calls or renders what changed?
5. What data now reaches a place it did not reach before?

When I want to check my own understanding of a change, ask me these and let me answer before you do. Do not turn it into a ritual on every change.

Also say whether the change was run where it will really run, such as a browser for UI, or a production-like load for anything that changes what is loaded at startup. "Tests pass" and "it works in the real environment" are different claims.

## Fresh eyes

The agent that designed or wrote something shares its own blind spots, and after a long session so do I. A reviewer that starts with no memory of the conversation does not, which is why a design that only makes sense with the conversation behind it fails in front of one. Use a fresh subagent for this, given only the written design and the files it references, never a summary of what was discussed and never your own conclusions. A review done in the same context is not this review. Use it when the change is risky enough to deserve it, not on every change.

- **Comprehension check.** Ask the fresh reviewer to say back, from the document alone, what the change does: the state, the transitions, and who owns what. Show me that paraphrase next to the intent. Where the two differ, the design is unclear or wrong on paper, and I can see it in a minute without reading the whole design again.
- **Design review through these lenses.** Ask the fresh reviewer for what this skill cares about, not for general feedback: a transition with no answer for twice, concurrent, or halfway, a contract that says what it returns but not what it accepts, a caller that has to know how the layer below works, and a boundary that moves without being stated.
- **Drift check after implementation.** Have a fresh reviewer compare the agreed design with the code that was written, and report where they differ. This is the direct way to find a boundary that moved by accident, or a transition that was implemented differently from what I accepted.

A fresh reviewer produces a lot of findings, and passing them all on would cost me the attention this is meant to save. Triage them first: for each one, either propose the fix or say why you contest it, and bring me only the ones that change a decision. Re-check once after fixing. What is still open after that is a trade-off to state, not a reason for another round.

## How to show me things

- **Bottom line first.** Open with what I have to decide right now and what is blocked until I do, before any explanation. Put each decision as a question I can answer in a few words, with your recommendation and the one reason behind it. If nothing needs a decision, say that first, so I know the rest is for reading and not for answering. Then give the supporting detail below, in order of how much it matters to those decisions, and after that the things I may want to comment on but that do not block anything. I should be able to stop reading after the first block and still unblock you.
- **Short.** I am trying to protect my attention. Anything long gets skimmed, which is the failure this skill exists to prevent. Select what matters instead of covering everything.
- **Pictures for structure.** State machines, boundaries, and where the coupling line sits are diagrams, not prose.
- **Decisions named as decisions.** A boundary move, a patch chosen over a design, and an untested gap are my calls. Each one belongs in that opening block as its own choice, never inside the detail below it, so that agreeing with the whole does not silently approve it.
- **Unknowns stated.** "I did not check this" is more useful to me than a confident summary.
