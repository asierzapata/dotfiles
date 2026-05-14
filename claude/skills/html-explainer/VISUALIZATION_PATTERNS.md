# Visualization Patterns

A catalog of techniques HTML opens up beyond prose and boxed diagrams. Use it as a starting point, not a limit. The goal is to pick a representation that teaches faster than text could.

## The Mandate

For every major section in the explainer, aim for at least one element that's non-static. Animation, scrubber, toggle, hover-reveal, scroll-pin, click-to-advance, anything that responds. A section that's only headings, paragraphs, and a boxed diagram is usually weaker than one with a single well-chosen interactive element.

This is a guideline, not a hard rule. A short, prose-only section can be the right call. But don't *default* to prose-only without asking the question below.

For every major lesson, ask one question before defaulting to prose:

> Is there a state, a quantity, a sequence, a comparison, or a hierarchy here that a visual would teach faster?

If yes, pick a pattern from the catalog (or invent one). Justify the choice in one line in the brief or in a comment.

## How to Pick

A rough decision tree, from easiest to hardest to choose:

| The lesson is about... | Try one of |
| --- | --- |
| Something that changes over time | Step-through simulator, time scrubber, animated state machine |
| A quantity that varies a lot in scale | Log-scale magnitude bars, animated counter, sparkline |
| A sequence of messages between actors | Autoplay sequence, particle-on-path |
| Two states to compare | Before/after slider, side-by-side compare block |
| Parallel work | Swim-lanes |
| Code behavior at the line level | Hover-annotated code |
| A "big concept moment" | Full-bleed diagram, sticky diagram + scrolling text |
| One architecture, two execution paths | Dual-mode architecture diagram |
| A multi-actor protocol | UML sequence diagram with step scrubber |
| Two patterns that aren't directly comparable | Paired mini-replay cards |
| A tree, taxonomy, or class hierarchy | Hierarchy tree (SVG) |
| Events along a time axis (deploys, releases, incidents) | Horizontal version timeline |

When in doubt, pick the simpler one. A static SVG that teaches beats a fancy animation that distracts.

---

## 1. Step-through Simulator

**Teaches:** state that evolves in discrete ticks. The reader clicks "advance" and sees the next state. Great for queues, schedulers, retry budgets.

**Effort:** low.

```html
<div class="sim" id="queue-sim">
  <div class="sim-state" data-step="0">
    <div class="sim-label">tick 0 — work enqueued, status pending</div>
    <div class="sim-row"><span class="chip pending">W1</span></div>
  </div>
  <div class="sim-state" data-step="1" hidden>
    <div class="sim-label">tick 1 — worker claims W1, status processing</div>
    <div class="sim-row"><span class="chip processing">W1</span></div>
  </div>
  <div class="sim-state" data-step="2" hidden>
    <div class="sim-label">tick 2 — handler throws, scheduled for retry</div>
    <div class="sim-row"><span class="chip pending">W1 (attempt 2)</span></div>
  </div>
  <button class="sim-advance">advance →</button>
  <button class="sim-reset">reset</button>
</div>
<script>
  document.querySelectorAll('.sim').forEach(sim => {
    const states = sim.querySelectorAll('.sim-state')
    let i = 0
    const show = () => states.forEach((s, k) => (s.hidden = k !== i))
    sim.querySelector('.sim-advance').onclick = () => { i = (i + 1) % states.length; show() }
    sim.querySelector('.sim-reset').onclick = () => { i = 0; show() }
  })
</script>
```

Why this pattern: discrete time is hard to read in prose, easy to read in a sequence of frames the reader controls.

---

## 2. Time Scrubber

**Teaches:** continuous progress along a timeline. Drag a handle, watch a value, a chart, or a state update. Great for showing retry backoff over hours, deploy windows, or animation timing curves.

**Effort:** medium.

```html
<div class="scrubber">
  <input type="range" id="attempt" min="1" max="10" value="1" step="1" />
  <div class="scrubber-readout">
    <div>Attempt: <span id="attempt-n">1</span></div>
    <div>Backoff: <span id="attempt-backoff">1s</span></div>
    <div>Cumulative wait: <span id="attempt-cum">1s</span></div>
  </div>
</div>
<script>
  const fmt = s => s < 60 ? s + 's' : (s / 60).toFixed(1) + 'min'
  const slider = document.getElementById('attempt')
  slider.oninput = () => {
    const n = +slider.value, backoff = Math.pow(3, n - 1)
    let cum = 0; for (let i = 1; i <= n; i++) cum += Math.pow(3, i - 1)
    document.getElementById('attempt-n').textContent = n
    document.getElementById('attempt-backoff').textContent = fmt(backoff)
    document.getElementById('attempt-cum').textContent = fmt(cum)
  }
</script>
```

Why this pattern: the reader sets the scale that matters to them. A scrubber teaches "this gets nonlinear fast" in seconds.

---

## 3. Animated State Machine

**Teaches:** legal transitions between states. Hover or click a transition arrow, the next state lights up. Great for workflow journals, claim leases, work statuses.

**Effort:** medium. Use inline SVG.

```html
<svg viewBox="0 0 480 200" class="state-machine">
  <g class="node" id="sm-pending">
    <rect x="20" y="60" width="100" height="60" rx="8" />
    <text x="70" y="95" text-anchor="middle">pending</text>
  </g>
  <g class="node" id="sm-processing">
    <rect x="190" y="60" width="100" height="60" rx="8" />
    <text x="240" y="95" text-anchor="middle">processing</text>
  </g>
  <g class="node" id="sm-done">
    <rect x="360" y="60" width="100" height="60" rx="8" />
    <text x="410" y="95" text-anchor="middle">succeeded</text>
  </g>
  <path class="edge" id="sm-claim" d="M120 90 L190 90" marker-end="url(#a)" />
  <path class="edge" id="sm-complete" d="M290 90 L360 90" marker-end="url(#a)" />
  <defs>
    <marker id="a" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M0 0 L10 5 L0 10 z" fill="currentColor" />
    </marker>
  </defs>
</svg>
<p class="sm-caption">Hover an arrow to see the transition.</p>
<style>
  .state-machine .node rect { fill: var(--panel); stroke: var(--gunmetal-3); }
  .state-machine .edge { stroke: var(--gunmetal-3); fill: none; stroke-width: 2; transition: stroke 0.2s; }
  .state-machine .edge:hover { stroke: var(--layer-accent); cursor: pointer; }
  .state-machine .edge:hover ~ .node rect { opacity: 0.5; }
</style>
```

Why this pattern: a state machine drawn flat invites the question "who can call which transition?" An interactive one answers it.

---

## 4. Autoplay Sequence

**Teaches:** a conversation between actors. Use it for dispatcher-worker-handler interactions, request-response chains, event flows. The reader hits play and the arrows light up in order.

**Effort:** medium.

Implementation sketch: render each message as an SVG line with a `<animate>` element keyed to a play button, or use CSS `@keyframes` with `animation-play-state: paused` flipping to `running`. Group steps into a `<g>` and stagger their `animation-delay`.

For non-loop linear playback, the simplest approach is staggered CSS opacity + `transform: translateY` per step, triggered by adding a class on the container.

---

## 5. Sparkline

**Teaches:** trend in a small space, inline with text. Use it for "this number has been climbing", "this metric is bumpy", or to put a real chart inside a paragraph.

**Effort:** low.

```html
<p>The cumulative wait grows non-linearly
  <svg class="sparkline" viewBox="0 0 100 20" preserveAspectRatio="none">
    <polyline points="0,19 11,18.9 22,18.7 33,18 44,16 55,12 66,6 77,3 88,1.5 100,0.5"
      fill="none" stroke="currentColor" stroke-width="1.5" />
  </svg>
  with each retry attempt.
</p>
<style>
  .sparkline { width: 80px; height: 16px; color: var(--layer-accent); vertical-align: middle; margin: 0 4px; }
</style>
```

Why this pattern: a number gains meaning when it has shape. A sparkline costs five lines and adds context to a sentence.

---

## 6. Log-Scale Magnitude Bars

**Teaches:** ranges that linear bars hide. When values span "1 second to 3 hours", linear bars make the small end disappear. Log scale shows everyone.

**Effort:** low.

Same HTML as the budget-table from `REFERENCE.md`, but compute widths as `Math.log10(value) / Math.log10(max) * 100` instead of `value / max * 100`. Add a small note under the table:

```html
<p class="scale-note">Bars use log scale so small values stay visible.</p>
<style>
  .scale-note { color: var(--muted); font-size: 12px; font-style: italic; margin: 4px 0 0; }
</style>
```

Why this pattern: faithful charts beat dramatic charts. If the lesson is "this grows fast", a log scale is more honest than truncating the axis.

---

## 7. Particle-on-Path

**Teaches:** flow of a thing through a system. A dot moves along the arrows of a diagram, showing where the work goes. Great for dispatcher-to-handler journeys, message-bus flows.

**Effort:** medium.

```html
<svg viewBox="0 0 480 60" class="path-flow">
  <path id="route" d="M30 30 L150 30 L300 30 L450 30"
        fill="none" stroke="var(--gunmetal-3)" stroke-width="2" />
  <circle r="6" fill="var(--layer-accent)">
    <animateMotion dur="3s" repeatCount="indefinite">
      <mpath href="#route" />
    </animateMotion>
  </circle>
</svg>
```

Pair with labels above the path (Caller, Dispatcher, Workpool, Handler). Animation can be paused with a button that toggles the `<animateMotion>` element's `begin` attribute or the SVG's `pauseAnimations()` API.

Why this pattern: a flow that moves answers "what is this diagram trying to show?" before the reader has to ask.

---

## 8. Before/After Slider

**Teaches:** what changed between two states. Drag a vertical handle to wipe between the two. Use it for code refactors, design changes, "before this PR landed" vs "after".

**Effort:** medium.

```html
<div class="ba">
  <div class="ba-after">After: maxAttempts = 10, base = 3 (~2h 44m)</div>
  <div class="ba-before" id="ba-before">Before: maxAttempts = 3, base = 2 (~7s)</div>
  <input type="range" min="0" max="100" value="50" class="ba-handle" id="ba-handle" />
</div>
<style>
  .ba { position: relative; height: 80px; border: 1px solid var(--border); border-radius: var(--r-md); overflow: hidden; }
  .ba-after, .ba-before { position: absolute; inset: 0; display: flex; align-items: center; padding: 0 var(--u5); }
  .ba-after { background: var(--golf-light); }
  .ba-before { background: var(--coral-light); clip-path: inset(0 0 0 50%); }
  .ba-handle { position: absolute; inset: 0; width: 100%; opacity: 0; cursor: ew-resize; }
</style>
<script>
  document.getElementById('ba-handle').oninput = e => {
    document.getElementById('ba-before').style.clipPath = `inset(0 0 0 ${e.target.value}%)`
  }
</script>
```

Why this pattern: a wipe shows two states are the same shape with one variable changed. Side-by-side cards don't make that as clearly.

---

## 9. Hover-Annotated Code

**Teaches:** what each line of a code block does, on demand. Hover a line, see the explanation in a side rail. Better than mid-block comments for non-trivial code.

**Effort:** low.

```html
<div class="code-annotated">
  <pre class="code"><span class="ln" data-note="Checks if we've already used our retry budget.">if (attempts >= retryBehaviour.maxAttempts) return false</span>
<span class="ln" data-note="Every error type retries the same way (post #22209).">return true</span></pre>
  <aside class="code-note" id="code-note">Hover a line to see what it does.</aside>
</div>
<style>
  .code-annotated { display: grid; grid-template-columns: 2fr 1fr; gap: var(--u4); align-items: start; }
  .code-annotated .ln { display: block; padding: 0 var(--u2); border-radius: 2px; cursor: pointer; }
  .code-annotated .ln:hover { background: var(--layer-soft); }
  .code-note { font-size: 13.5px; color: var(--gunmetal-1); border-left: 2px solid var(--layer-accent); padding-left: var(--u3); }
</style>
<script>
  document.querySelectorAll('.code-annotated .ln').forEach(ln => {
    ln.onmouseenter = () => (document.getElementById('code-note').textContent = ln.dataset.note)
  })
</script>
```

Why this pattern: line-by-line teaching without polluting the snippet with comments. The reader chooses depth.

---

## 10. Swim-Lanes

**Teaches:** parallel work across actors. Use it for "the API request returns immediately while the worker continues running for 40 minutes", or "step A and step B run concurrently".

**Effort:** medium.

```html
<div class="lanes">
  <div class="lane">
    <div class="lane-label">API request</div>
    <div class="lane-track">
      <div class="lane-bar" style="left: 0; width: 8%">dispatch + enqueue</div>
    </div>
  </div>
  <div class="lane">
    <div class="lane-label">Worker</div>
    <div class="lane-track">
      <div class="lane-bar lane-ghost" style="left: 8%; width: 4%">claim</div>
      <div class="lane-bar" style="left: 12%; width: 80%">run handler (40 min)</div>
    </div>
  </div>
</div>
<style>
  .lanes { display: grid; gap: var(--u2); margin: var(--u5) 0; }
  .lane { display: grid; grid-template-columns: 120px 1fr; gap: var(--u3); align-items: center; }
  .lane-label { font-family: var(--mono); font-size: 12px; color: var(--muted); text-align: right; }
  .lane-track { position: relative; height: 32px; background: var(--gunmetal-6); border-radius: var(--r-sm); }
  .lane-bar { position: absolute; top: 4px; bottom: 4px; background: var(--layer-accent); color: var(--white); font-size: 11px; padding: 0 var(--u2); display: flex; align-items: center; border-radius: 3px; }
  .lane-bar.lane-ghost { background: var(--gunmetal-4); color: var(--gunmetal-1); }
</style>
```

Why this pattern: parallelism is invisible in prose. Lanes show that the API call already finished by the time the worker starts.

---

## 11. Full-Bleed Diagram

**Teaches:** the big concept moment. Break the column width to give a diagram room to breathe. Use sparingly, once per layer at most.

**Effort:** low. Just CSS.

```html
<div class="full-bleed">
  <div class="diagram"><!-- big diagram --></div>
</div>
<style>
  .full-bleed {
    width: 100vw;
    margin-left: calc(50% - 50vw);
    padding: 0 var(--u6);
  }
</style>
```

Why this pattern: a full-width diagram says "this is the picture, study it". A column-width diagram says "this is supporting evidence". Choose deliberately.

---

## 12. Sticky Diagram + Scrolling Text

**Teaches:** a complex diagram with multiple parts the reader needs to follow as we narrate. The diagram pins to the top of the viewport while paragraphs explain each part in sequence.

**Effort:** medium.

```html
<section class="sticky-pair">
  <aside class="sticky-pair-fig">
    <div class="diagram"><!-- the diagram --></div>
  </aside>
  <div class="sticky-pair-text">
    <p>First, the Dispatcher writes a journal...</p>
    <p>Then it enqueues the action...</p>
    <p>The worker claims it under a lease...</p>
    <p>The handler runs and returns...</p>
  </div>
</section>
<style>
  .sticky-pair { display: grid; grid-template-columns: 1fr 1fr; gap: var(--u8); margin: var(--u8) 0; }
  .sticky-pair-fig { position: sticky; top: 80px; align-self: start; }
  .sticky-pair-text p { min-height: 60vh; }
  @media (max-width: 720px) { .sticky-pair { grid-template-columns: 1fr; } .sticky-pair-fig { position: static; } }
</style>
```

Why this pattern: a long explanation paired with one durable visual beats six small disposable diagrams. The reader builds a mental model around one anchor.

---

## 13. Dual-Mode Architecture Diagram

**Teaches:** one architecture, two execution paths through it. A pill toggle switches which edges/blocks are highlighted; the boxes don't move. Great for "immediate vs durable", "sync vs async", "happy path vs error path".

**Effort:** medium-high. Inline SVG + a few classes that toggle styling.

```html
<div class="arch-frame">
  <div class="arch-mode-toggle">
    <div class="transport-toggle" role="group">
      <button data-arch-mode="immediate" aria-pressed="true">immediate</button>
      <button data-arch-mode="durable" aria-pressed="false">durable</button>
    </div>
  </div>
  <svg class="arch-svg" id="arch-svg" viewBox="0 0 800 380">
    <!-- blocks: Dispatcher, Router, Pipeline, Workpool -->
    <!-- edges grouped by mode: .arch-flow.is-mode-immediate / .is-mode-durable -->
  </svg>
  <div class="arch-legend">
    <span class="leg-imm">immediate</span>
    <span class="leg-dur">durable</span>
  </div>
</div>
<script>
  document.querySelectorAll('[data-arch-mode]').forEach(btn => {
    btn.onclick = () => {
      const mode = btn.dataset.archMode
      document.querySelectorAll('[data-arch-mode]').forEach(b => b.setAttribute('aria-pressed', String(b === btn)))
      document.getElementById('arch-svg').dataset.mode = mode
    }
  })
</script>
```

Style the two edge sets with distinct strokes (`.is-mode-immediate` dashed pool, `.is-mode-durable` solid golf-deep). The active mode's edges go opaque, the other goes faded. See `workflows-ga-explainer.html` `.arch-frame` (line ~1516) for a working reference.

Why this pattern: a static "all arrows on at once" diagram forces the reader to mentally subtract; a toggle does that subtraction for them.

---

## 14. UML Sequence Diagram with Step Scrubber

**Teaches:** a multi-actor protocol where ordering, lifelines, and message direction all matter. Different from the autoplay sequence — this one has actors with vertical lifelines and cumulative messages, like a real sequence diagram. Use a "next step →" button or a range slider to advance.

**Effort:** high. Inline SVG built in JS so messages can be revealed cumulatively.

```html
<div class="scrub-frame">
  <div class="seq-wrap">
    <svg id="seq-svg" class="seq-svg" viewBox="0 0 1100 970"></svg>
  </div>
  <div class="seq-controls">
    <button id="seq-prev">← back</button>
    <span class="step-counter">Step <span id="seq-step">1</span> / <span id="seq-total">7</span></span>
    <button id="seq-next">next →</button>
  </div>
</div>
```

Construction notes:
- Render actor headers across the top (`Caller`, `Dispatcher`, `Worker`, `Handler`...) with vertical dashed lifelines under each.
- Each step adds a horizontal arrow between two lifelines plus an optional activation rectangle on the receiver's lifeline. Render incrementally: `steps.slice(0, i)` rather than wiping the whole SVG.
- Group related steps with a translucent frame (e.g., everything happening inside the Dispatcher gets a `<rect>` background).
- For short hops, center the label on the arrow; for long ones, anchor near the receiver. End the arrow line a few px short of the lifeline so the arrowhead has room.

See `workflows-ga-explainer.html` `.seq-svg` (line ~1645) for the full implementation including activation boxes and group frames.

Why this pattern: a protocol with 4+ actors and 6+ messages is illegible flattened to prose. A sequence diagram makes the ordering and the activation windows visible at a glance.

---

## 15. Paired Mini-Replay Cards

**Teaches:** two patterns side by side, each with its own short animation that the reader can replay. Different from before/after slider — these two animations run independently and show *different shapes*, not the same shape parameterized.

**Effort:** medium. Two cards, each with a small SVG and a replay button.

```html
<div class="coord-compare">
  <div class="coord-card" data-coord="orch">
    <div class="coord-tag">Pattern · Orchestration</div>
    <h4>One coordinator, a known sequence.</h4>
    <div class="coord-desc">A workflow names the flow and tells each participant what to do, in order.</div>
    <svg class="coord-svg" id="coord-orch-svg" viewBox="0 0 400 220"></svg>
    <button class="coord-replay" data-coord-replay="orch">↻ Replay</button>
  </div>
  <div class="coord-card" data-coord="cho" data-accent="bananas">
    <div class="coord-tag">Pattern · Choreography</div>
    <h4>One event, many independent reactions.</h4>
    <div class="coord-desc">A publisher emits a fact and anyone interested subscribes.</div>
    <svg class="coord-svg" id="coord-cho-svg" viewBox="0 0 360 220"></svg>
    <button class="coord-replay" data-coord-replay="cho">↻ Replay</button>
  </div>
</div>
```

Per-card animation is typically driven by adding `.is-active` / `.is-done` classes to SVG nodes on a `setInterval` triggered by the replay button. The second card overrides `data-accent` so the two animations read as different "color systems".

Why this pattern: when the two patterns aren't actually comparable on the same axis (orchestration and choreography have different shapes, not different values), a slider lies. Two separate replays let each tell its own story.

---

## 16. Hierarchy Tree (SVG)

**Teaches:** a class hierarchy, taxonomy, or any tree structure. Boxes connected by lines, with the root at the top or left. The catalog's diagram pattern is a single row; this is multi-level.

**Effort:** low-medium. Inline SVG, hand-positioned for small trees, or built in JS for larger ones.

```html
<div class="tree-svg-wrap">
  <svg class="tree-svg" id="tree-svg" viewBox="0 0 720 360">
    <!-- root -->
    <g class="tree-node is-root">
      <rect x="300" y="20" width="120" height="44" rx="8" />
      <text x="360" y="46" text-anchor="middle">Message</text>
    </g>
    <!-- children with connecting lines -->
    <path class="tree-edge" d="M360 64 V100 H180 V140" />
    <path class="tree-edge" d="M360 64 V100 H540 V140" />
    <g class="tree-node"><rect x="120" y="140" width="120" height="44" rx="8" />
      <text x="180" y="166" text-anchor="middle">Action</text></g>
    <g class="tree-node"><rect x="480" y="140" width="120" height="44" rx="8" />
      <text x="540" y="166" text-anchor="middle">Event</text></g>
    <!-- ...leaves... -->
  </svg>
</div>
```

For trees with more than ~10 nodes, generate the SVG in JS from a nested array. Use orthogonal edges (vertical + horizontal segments) rather than diagonals — easier to read.

Why this pattern: a tree in a code block (`├──`, `└──`) communicates structure but doesn't let nodes be styled, accented, or interacted with. SVG gives you all of that for not much more code.

---

## 17. Horizontal Version Timeline

**Teaches:** events along a time axis, with eras and deploy markers. Use it for "how a long-running thing behaves across deploys", versioning, release timelines, incident timelines.

**Effort:** medium. Positional CSS (`left: X%`) on absolutely-positioned children inside a `min-width`-anchored track.

```html
<div class="vtl-track">
  <div class="vtl-axis"></div>
  <div class="vtl-tick" style="left: 6%"><div class="vtl-label">T0</div></div>
  <div class="vtl-tick" style="left: 40%"><div class="vtl-label">Deploy</div></div>
  <div class="vtl-tick" style="left: 94%"><div class="vtl-label">Resume</div></div>

  <div class="vtl-era" style="left: 14%">— Old code running —</div>
  <div class="vtl-era" style="left: 60%; color: var(--orangina-deep)">— New code, old journal —</div>

  <div class="vtl-event is-above is-ok" style="left: 16%"><b>Step 1 OK</b>writes journal entry</div>
  <div class="vtl-event is-below" style="left: 28%"><b>Pause</b>awaiting next step</div>

  <div class="vtl-deploy" style="left: 44%">
    <div class="vtl-deploy-label">Deploy · insert ValidateAnalysisData @ #2</div>
  </div>

  <div class="vtl-event is-above is-fail" style="left: 70%"><b>Mismatch</b>step #2 shape changed</div>
</div>
```

Event boxes alternate above and below the axis with small connector stems (`::after` pseudo-elements). Deploy markers are a vertical bar with a circular cap; eras are mono-uppercase labels above the axis. See `workflows-ga-explainer.html` `.vtl-track` (line ~2031) for the full styling.

Why this pattern: deploy-spanning behavior is one of those concepts where prose under-sells how surprising the result is. A timeline with a literal "deploy" marker makes "the running workflow crossed a boundary" obvious.

---

## Anti-Patterns

- **Animation for animation's sake.** If the motion doesn't carry a lesson, cut it.
- **Interactivity that requires reading instructions.** If a control needs a sentence of explanation, it's the wrong control.
- **One pattern repeated across every layer.** Variety is part of the teaching. A page of scrubbers feels like a calculator, not an explainer.
- **Tiny tap targets.** Mobile readers exist. Buttons and handles should be at least 32px tall.
- **Pretty but unreadable charts.** Faithfully sized beats dramatically sized. Honesty teaches.
- **Reinventing what the catalog has.** Riff on these, then invent new ones. Don't waste time rebuilding what's here.

