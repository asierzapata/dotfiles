# HTML Explainer Reference

Design tokens and copy-paste component snippets for Edpuzzle-flavored HTML explainers. Pair this with [SKILL.md](./SKILL.md) and [BASE_TEMPLATE.html](./BASE_TEMPLATE.html). Navigation patterns live in [NAVIGATION_PATTERNS.md](./NAVIGATION_PATTERNS.md); visualization patterns in [VISUALIZATION_PATTERNS.md](./VISUALIZATION_PATTERNS.md).

## Design Tokens

All tokens live in `:root` in the shell. They mirror the codebase's design system.

### Palette

Sourced from `src/frontend/web/ui/identity/colors.scss`. Use the named vars, not raw hexes.

| Token | Hex | Role |
| --- | --- | --- |
| `--soymilk` | `#fcfbfa` | Page background |
| `--white` | `#ffffff` | Card / panel background |
| `--frost`, `--sky`, `--sky-light` | `#eef5fa`, `#ebf4fd`, `#f5f9fe` | Soft blue surfaces |
| `--martens` | `#333333` | Primary text |
| `--gunmetal-1..6` | `#434649 → #fafafa` | Greys (text, borders, surfaces) |
| `--pool` / `--pool-light` / `--pool-deep` | `#0c70eb` / `#deebff` / `#0a4388` | Primary accent (layer 1) |
| `--orangina` / `--orangina-light` / `--orangina-deep` | `#ff9900` / `#fbe2bc` / `#d26312` | Warning accent (layer 2) |
| `--verbena` / `--verbena-deep` | `#ecdcfa` / `#a458e5` | Orchestration accent (layer 3) |
| `--golf` / `--golf-light` / `--golf-deep` | `#0da07d` / `#e5f4f4` / `#036951` | Success accent (layer 4) |
| `--coral` / `--coral-light` | `#d13a40` / `#fdeded` | Error / warning callouts |
| `--bananas` / `--bananas-light` | `#ffc400` / `#fff4d3` | Highlight |

### Spacing — 4px unit grid

```
--u1: 4px   --u2: 8px   --u3: 12px  --u4: 16px
--u5: 20px  --u6: 24px  --u8: 32px  --u10: 40px
--u12: 48px --u16: 64px
```

Use these everywhere. No raw px values for margin/padding.

### Radii

```
--r-sm: 4px    (inline code, small chips)
--r-md: 8px    (cards, panels)
--r-lg: 12px   (large diagrams)
--r-xl: 16px   (showcase containers)
--r-pill: 9999px  (nav buttons, eyebrow, toggles)
```

### Typography

- Font stack: `'GT Pressura', Helvetica, Arial, sans-serif` (GT Pressura is brand, fallback covers external readers)
- Mono stack: `ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace`
- Sizes — H1 34px, H2 22px, H3 15px, lede 18px, body 15px (default), small/labels 13px, mono in body 0.88em
- Line-height 1.5 default, 1.15 for H1, 1.55 for ledes and code

### Shadows

```
--shadow-sm: 0 1px 2px rgba(51,51,51,0.06), 0 1px 1px rgba(51,51,51,0.04);
--shadow-md: 0 4px 12px rgba(51,51,51,0.08), 0 1px 2px rgba(51,51,51,0.04);
```

## Section Accent System

Accents are set via a `data-accent` attribute on `<body>` or any container. Two CSS variables, `--layer-accent` and `--layer-soft`, cascade through every accent-aware component. (The variable names start with `--layer-` for backwards compatibility; semantically they apply to any section, slide, or branch.)

```css
[data-accent='pool']     { --layer-accent: var(--pool);          --layer-soft: var(--pool-light); }
[data-accent='orangina'] { --layer-accent: var(--orangina-deep); --layer-soft: var(--orangina-light); }
[data-accent='verbena']  { --layer-accent: var(--verbena-deep);  --layer-soft: var(--verbena); }
[data-accent='golf']     { --layer-accent: var(--golf);          --layer-soft: var(--golf-light); }
[data-accent='coral']    { --layer-accent: var(--coral);         --layer-soft: var(--coral-light); }
[data-accent='bananas']  { --layer-accent: var(--bananas);       --layer-soft: var(--bananas-light); }
```

Components that pick up the accent: `.brand .dot`, active nav controls, `.eyebrow`, `.node.is-protagonist`, `.callout` (default variant), `.budget-table .bar`, code-block `.hi` highlight.

Usage notes:

- **Section-scoped accent.** Put `data-accent="..."` on the section element. Children inherit. Good for tabbed and accordion patterns.
- **Body-level accent.** Update `document.body.dataset.accent` in the nav handler as the active section changes. Good for transitions and for accent-aware chrome (brand dot, header nav).
- **Skip accents entirely.** A monochrome page is valid. Just leave `data-accent` off; the defaults in `:root` apply (pool / pool-light).
- **Adding new accents.** Pick a palette token and add a `[data-accent='name']` block. Keep `--layer-accent` saturated enough for white text contrast in pill buttons.

## Page Chrome

These four components form the recurring scaffolding of an explainer. They sit *around* per-section content. Use them together: the hero opens the page, chapter cards open each section, the TOC brand identifies the publication, and the footer closes it.

### Hero block

The display-sized opener. Eyebrow + h1 with one or two accent-colored words + lede + a meta row with run-time / authors / date. The hero gets the page's primary accent (usually `pool`) and a subtle blueprint grid in the background.

```html
<section id="s-hero" data-accent="pool" class="hero">
  <div class="eyebrow">{{Publication · Edition label}}</div>
  <h1>
    Workflows, and the move to separating
    <span class="accent">intent</span> from <span class="accent">consequence</span>
  </h1>
  <p class="lede">
    {{Two or three sentences. What this page covers and why a reader should care.}}
  </p>
  <div class="hero-meta">
    <div><span>Read time</span><b>~ 15 minutes</b></div>
    <div><span>Presenters</span><b>Platform team</b></div>
  </div>
</section>
```

The `.accent` spans inside `h1` pick up `--layer-deep` and italicize — they're the place to give the headline rhythm. Limit to one or two words.

### Chapter card

Every major section opens with one. Big chapter number in the top-right, eyebrow, h2 chapter title, one-sentence lede. Wrapped in a layer-tinted card with a 4px accent stripe across the top.

```html
<section id="s-background" data-accent="pool">
  <div class="chapter-card">
    <div class="chapter-num">Ch. 01</div>
    <div class="eyebrow">Background</div>
    <h2>Where we were coming from, and the cracks we kept hitting</h2>
    <p class="chapter-lede">
      {{One sentence framing the chapter. Not a summary — a promise.}}
    </p>
  </div>

  <!-- chapter content follows -->
</section>
```

The `.chapter-lede` is the most consequential sentence in the chapter. Write it last, when you know what the chapter actually delivers.

### Publication-style TOC brand

A small two-line brand block at the top of the sticky TOC. Uppercase publication name in mono, a slash in the accent color, and the section/edition name in display weight. Reads like the masthead of a magazine.

```html
<aside class="toc">
  <div class="toc-brand">
    <span class="pub">Edpuzzle</span>
    <span class="title"><span class="slash" aria-hidden="true">/</span>Engineering</span>
  </div>
  <div class="toc-meta">Explainer</div>
  <div class="toc-title">On this page</div>
  <ul class="toc-tree"><!-- ...links... --></ul>
</aside>
```

Pair with the long-form scroll TOC pattern from `NAVIGATION_PATTERNS.md`. The slash is decorative; keep it `aria-hidden`.

### Site footer (with the badger easter egg)

Every explainer closes with the same footer: a small mono-uppercase mark, a "Made by badgers" line, and the badger easter egg trigger. This is the **standing convention** across the explainer family — don't reinvent it per page. Continuity is the point: a returning reader recognizes the closing the way they recognize the masthead.

```html
<footer class="site-footer">
  <div class="foot-mark"><span class="slash">/</span>Edpuzzle Engineering</div>
  <div class="foot-flavor">
    Made by badgers · <button class="badger-trigger" aria-label="surprise">🦡</button>
  </div>
</footer>
```

The badger button triggers an easter egg (e.g., make it rain badgers, animated mascot, hidden replay). See `workflows-ga-explainer.html` `.badger-trigger` for the rain-badgers implementation as the canonical reference.

**Per-page personality moment is additive, not a replacement.** The badger footer is the constant. If a page wants an extra delight — a footnote with a Slack-thread quote, a hidden replay button mid-page, an animated callout that only fires once — layer it on top. Don't drop the badger.

## Page Anatomy

There is no single required section anatomy. The two universal pieces are a brand identifier and a content area. Everything between depends on the navigation pattern.

A typical minimal section:

```html
<section data-accent="pool">
  <div class="eyebrow">{{label}}</div>
  <h1>{{One declarative sentence.}}</h1>
  <p class="lede">{{Two or three sentences naming what this section covers.}}</p>

  <!-- visualization (optional, picked per [VISUALIZATION_PATTERNS.md]) -->
  <!-- supporting prose, code, callouts -->
  <!-- file ref list when citing code -->
</section>
```

Section ordering is not prescribed. Sequential build-up, parallel parts of a whole, and reference-style jumps are all valid. Match the navigation pattern to the material.

## Component Library

The HTML snippets below assume the component CSS is loaded. The base template ships only with tokens and typography; copy the CSS for the components you use from the **Component CSS** appendix at the bottom of this file into `BASE_TEMPLATE.html`'s `<style>` block.

### Hero diagram (flow of nodes)

A horizontal row of boxed nodes with arrow separators. Use it for sequences (A → B → C → D). The `is-protagonist` variant picks up the section accent; reserve it for the node that represents the focus of the section.

```html
<div class="diagram">
  <div class="flow">
    <div class="node">
      A
      <span class="sub">short caption</span>
    </div>
    <span class="arrow">→</span>
    <div class="node is-protagonist">
      B
      <span class="sub">the focus of this section</span>
    </div>
    <span class="arrow">→</span>
    <div class="node is-framework">C<span class="sub">supporting piece</span></div>
    <span class="arrow">→</span>
    <div class="node is-userland">D<span class="sub">user code</span></div>
  </div>
  <div class="diagram-bracket">
    <span class="label">Optional bracket label</span>
  </div>
</div>
```

Variants:
- `.node` — neutral default
- `.node.is-framework` — soft blue, for framework / infrastructure pieces (was `.is-fabric`)
- `.node.is-protagonist` — accent fill, for the focus of the section (was `.is-dispatcher`)
- `.node.is-userland` — white, for user-land code (was `.is-handler`)

The older class names (`is-fabric`, `is-dispatcher`, `is-handler`) still work as aliases for backwards compatibility.

Arrow symbols: `→` for forward flow, `⟳` for loops/feedback.

### Two-state pill toggle

For interactive bits that flip a label or a hint. Buttons use `aria-pressed`; the JS handler updates the surrounding text.

```html
<div class="transport-toggle" role="group" aria-label="Transport">
  <button data-transport="immediate" aria-pressed="true">immediate</button>
  <button data-transport="durable" aria-pressed="false">durable</button>
</div>
<p id="transport-hint">The handler runs in-process and we await the result.</p>
```

```js
const buttons = document.querySelectorAll('.transport-toggle button')
const hint = document.getElementById('transport-hint')
const copy = { immediate: '...', durable: '...' }
buttons.forEach(btn => {
  btn.addEventListener('click', () => {
    buttons.forEach(b => b.setAttribute('aria-pressed', String(b === btn)))
    hint.textContent = copy[btn.dataset.transport]
  })
})
```

### Code block

Light-themed, with three syntax tokens (`.kw`, `.str`, `.com`) and a highlight span (`.hi`) that picks up the layer accent. The mark-up is hand-rolled, no highlighter library.

```html
<pre class="code"><span class="com">// shared/fabric/actions/dispatcher/index.js</span>
async <span class="kw">dispatch</span>(action, { dispatch = <span class="str">'immediate'</span> } = {}) {
    if (dispatch === <span class="str">'durable'</span>) {
        return this.#dispatchActionDurably(action)   <span class="com">// → Workpool</span>
    }
    return this.#dispatchActionImmediately(action)
}</pre>
```

Use `<span class="hi">...</span>` to draw the reader's eye to the line that matters. One highlight per block, not more.

### Side-by-side comparison

For "bad pattern vs good pattern" or "before vs after". Collapses to one column at 720px.

```html
<div class="compare">
  <div class="bad">
    <h4>✗ Smell — durability baked into the class</h4>
    <pre class="code" style="margin: 0">...</pre>
  </div>
  <div class="good">
    <h4>✓ Better — durability at the call site</h4>
    <pre class="code" style="margin: 0">...</pre>
  </div>
</div>
```

The `.bad` variant gets a coral H4, `.good` gets golf-deep. Headings are mono-uppercase.

### Callout

Three flavors. The default picks up the layer accent. Use `is-warn` for footguns (coral), `is-good` for "this is the default behavior we want" (golf).

```html
<div class="callout">
  <span class="ico">Rule</span>
  <p>Any time we feel tempted to name a class <code>Durable&lt;Something&gt;</code>, push the decision to the dispatch call instead.</p>
</div>

<div class="callout is-warn">
  <span class="ico">Mistake</span>
  <p>Assuming exactly-once execution. The crash-mid-write window still exists.</p>
</div>

<div class="callout is-good">
  <span class="ico">Default</span>
  <p>Cross-module event reactions are durable by default.</p>
</div>
```

The `.ico` label is a short uppercase word (Rule, Cost, Mistake, Default, Alert, Note). Keep it under 12 characters so it doesn't dominate.

### State cards (lifecycle / status)

Four cards in a row, each with a colored top border. Good for "the X states of Y".

```html
<div class="states">
  <div class="state s-pending">
    <div class="state-name">pending</div>
    <div class="state-body">Waiting in the queue. <code>availableAt</code> says when it becomes eligible.</div>
  </div>
  <div class="state s-processing">...</div>
  <div class="state s-ok">...</div>
  <div class="state s-fail">...</div>
</div>
```

Variants: `s-pending` (pool), `s-processing` (orangina), `s-ok` (golf), `s-fail` (coral). Use these semantics consistently across explainers so readers learn the visual code.

### Outcome cards (3-way taxonomy)

Three cards for a categorical breakdown ("cached / attributes changed / new step"). Top border picks the meaning color.

```html
<div class="outcomes">
  <div class="outcome is-cached">
    <h4>✓ cached</h4>
    <p>Type and attributes match an unconsumed entry.</p>
    <p style="color: var(--muted)">Chain <code>[A{1}, B{2}]</code>, code <code>A{1}, B{2}</code></p>
  </div>
  <div class="outcome is-attrs">...</div>
  <div class="outcome is-new">...</div>
</div>
```

Variants: `is-cached` (golf), `is-attrs` (orangina), `is-new` (verbena).

### Budget / data table with bars

A table with a numeric column rendered as proportional fill bars in the rightmost cell. Use it for retry budgets, latency tables, anything where the magnitude is part of the lesson.

```html
<table class="budget-table">
  <thead>
    <tr>
      <th>Attempt</th><th>Backoff</th><th>Cumulative</th><th class="bar-cell">Time to drop</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>1</td><td class="mono">1s</td><td class="mono">1s</td><td><div class="bar"><span style="width:0.01%"></span></div></td></tr>
    ...
    <tr class="drop"><td>10</td><td>—</td><td class="mono">drop</td><td>permanent failure</td></tr>
  </tbody>
</table>
```

The `.drop` row is the terminal case, rendered in coral. Bar widths are relative to the largest value in the table.

### File reference list

The closing block of every section. Lists the actual files the reader should open. Always include the documentation that backs the section.

**Always link, never just name-drop.** Each entry is an `<a>` tag pointing to the file on GitHub (or wherever the canonical version lives), not plain text. A linked reference list lets the reader jump straight to the code; an unlinked one is just decoration.

```html
<div class="ref-list">
  <div class="ref-title">Read these together</div>
  <ul>
    <li>
      <a href="https://github.com/edpuzzle/edpuzzle-web/blob/master/src/backend/packages/workpool/workpool.js">
        src/backend/packages/workpool/workpool.js
      </a>
      <span class="ref-note"> — facade, enqueueAction</span>
    </li>
    <li>
      <a href="https://github.com/edpuzzle/edpuzzle-web/blob/master/documentation/platforms/backend/explanation/durability-and-the-workpool/index.md">
        documentation/platforms/backend/explanation/durability-and-the-workpool/index.md
      </a>
      <span class="ref-note"> — full explanation</span>
    </li>
  </ul>
</div>
```

Format: `<a>`-wrapped path + a short trailing description in `.ref-note` muted gray. The repo base URL goes in a CSS variable or shared constant at the top of the file so it can be updated in one place.

**Inline citations in prose.** Beyond the closing ref-list, cite files **inline within paragraphs** when a sentence makes a claim that lives in a specific file. Use a small `<a class="cite">` linking to the file. This is the difference between an explainer that feels grounded (every claim is anchored) and one that feels hand-wavy.

```html
<p>
  The Journal is a Mongo document validated by a zod schema in
  <a class="cite" href="https://github.com/.../journal/journal.js">
    <code>journal.js</code>
  </a>.
</p>
```

A page should have **many** inline citations, not just one at the bottom. If a section names a class or a file but doesn't link to it, that's a missed citation.

## Anti-Patterns

- **A wall of placeholder lorem ipsum.** If a section needs real content to teach, write the real content. If it doesn't, cut it.
- **Decorative animation.** Every interactive piece must teach a lesson.
- **External fonts, frameworks, icon libraries.** The file should drop into any static host and work. The cost of a dependency is the file no longer being self-contained.
- **Mixing dark and light themes.** Pick light. The Edpuzzle product is light, the explainer matches.
- **Stale code blocks.** Re-verify every code block against the current source before publishing. Docs go stale fast.
- **Inventing color tokens.** Stay inside the palette. The named tokens are the language; ad-hoc hex values aren't.
- **Burying the lesson.** Each H2 section makes one point. If a section has two points, split it.

---

## Component CSS Appendix

Copy what you use into `BASE_TEMPLATE.html`'s `<style>` block. Every snippet assumes the tokens and typography from the base template are already loaded.

### Diagram + flow nodes

```css
.diagram {
  background: var(--panel);
  border: 1px solid var(--border);
  border-radius: var(--r-lg);
  padding: var(--u8) var(--u6);
  margin: var(--u6) 0;
  box-shadow: var(--shadow-sm);
}
.flow {
  display: flex; align-items: center; justify-content: center;
  flex-wrap: wrap; gap: var(--u2);
}
.node {
  display: flex; flex-direction: column; align-items: center;
  min-width: 96px;
  padding: var(--u3) var(--u4);
  background: var(--gunmetal-6);
  border: 1px solid var(--gunmetal-4);
  border-radius: var(--r-md);
  font-size: 13px; font-weight: 500; color: var(--text);
}
.node .sub {
  font-family: var(--mono); font-size: 11px;
  color: var(--muted); margin-top: 2px; font-weight: 400;
}
.node.is-framework, .node.is-fabric {
  background: var(--sky-light);
  border-color: var(--pool-light);
  color: var(--pool-deep);
}
.node.is-protagonist, .node.is-dispatcher {
  background: var(--layer-soft);
  border-color: var(--layer-accent);
  color: var(--layer-accent);
  font-weight: 600;
}
.node.is-userland, .node.is-handler {
  background: var(--white);
  border-color: var(--gunmetal-3);
}
.arrow {
  color: var(--gunmetal-3); font-size: 18px;
  font-family: var(--mono); padding: 0 var(--u1); user-select: none;
}
.diagram-bracket, .fabric-bracket {
  margin-top: var(--u4); text-align: center;
  font-size: 11px; font-family: var(--mono);
  color: var(--muted);
  letter-spacing: 0.06em; text-transform: uppercase;
}
.diagram-bracket .label, .fabric-bracket .label {
  display: inline-block;
  border-top: 1px solid var(--gunmetal-3);
  padding-top: var(--u2);
  min-width: 320px;
}
```

### Code blocks

```css
pre.code {
  background: var(--gunmetal-6);
  border: 1px solid var(--gunmetal-4);
  border-radius: var(--r-md);
  padding: var(--u4) var(--u5);
  font-family: var(--mono); font-size: 13px; line-height: 1.55;
  overflow-x: auto; color: var(--gunmetal-1);
  margin: var(--u3) 0 var(--u5);
}
pre.code .kw  { color: var(--verbena-deep); font-weight: 500; }
pre.code .str { color: var(--golf-deep); }
pre.code .com { color: var(--muted); font-style: italic; }
pre.code .hi  { background: var(--layer-soft); border-radius: 3px; padding: 0 3px; }
```

### Callouts

```css
.callout {
  display: flex; gap: var(--u4);
  background: var(--layer-soft);
  border-left: 3px solid var(--layer-accent);
  border-radius: var(--r-sm);
  padding: var(--u4) var(--u5);
  margin: var(--u5) 0;
  font-size: 14.5px;
}
.callout.is-warn { background: var(--coral-light); border-left-color: var(--coral); }
.callout.is-good { background: var(--golf-light); border-left-color: var(--golf); }
.callout .ico {
  font-family: var(--mono); font-size: 12px; font-weight: 700;
  letter-spacing: 0.05em; text-transform: uppercase;
  color: var(--layer-accent);
  flex-shrink: 0; padding-top: 2px;
}
.callout.is-warn .ico { color: var(--coral); }
.callout.is-good .ico { color: var(--golf-deep); }
.callout p:last-child { margin-bottom: 0; }
```

### Two-state pill toggle

```css
.transport-toggle {
  display: flex; justify-content: center;
  margin: var(--u6) auto var(--u2);
  gap: var(--u1);
  background: var(--gunmetal-5);
  border-radius: var(--r-pill);
  padding: var(--u1);
  width: max-content;
}
.transport-toggle button {
  border: 0; background: transparent;
  color: var(--muted);
  font-family: inherit; font-size: 13px; font-weight: 500;
  padding: var(--u2) var(--u4);
  border-radius: var(--r-pill);
  cursor: pointer;
  transition: background 0.15s ease, color 0.15s ease;
}
.transport-toggle button[aria-pressed='true'] {
  background: var(--white); color: var(--text);
  box-shadow: var(--shadow-sm);
}
```

### Side-by-side comparison

```css
.compare {
  display: grid; grid-template-columns: 1fr 1fr;
  gap: var(--u4); margin: var(--u5) 0;
}
@media (max-width: 720px) { .compare { grid-template-columns: 1fr; } }
.compare > div {
  background: var(--panel);
  border: 1px solid var(--border);
  border-radius: var(--r-md);
  padding: var(--u5);
}
.compare h4 {
  font-size: 13px; font-family: var(--mono);
  text-transform: uppercase; letter-spacing: 0.06em;
  margin: 0 0 var(--u3); color: var(--muted); font-weight: 600;
}
.compare .bad h4  { color: var(--coral); }
.compare .good h4 { color: var(--golf-deep); }
```

### State cards

```css
.states {
  display: grid; grid-template-columns: repeat(4, 1fr);
  gap: var(--u3); margin: var(--u5) 0;
}
@media (max-width: 720px) { .states { grid-template-columns: 1fr 1fr; } }
.state {
  background: var(--panel);
  border: 1px solid var(--border);
  border-radius: var(--r-md);
  padding: var(--u4);
  border-top: 3px solid var(--gunmetal-3);
}
.state-name {
  font-family: var(--mono); font-size: 12px; font-weight: 600;
  text-transform: uppercase; letter-spacing: 0.05em;
  margin-bottom: var(--u2); color: var(--text);
}
.state-body { font-size: 13.5px; color: var(--gunmetal-1); line-height: 1.5; }
.state.s-pending    { border-top-color: var(--pool); }
.state.s-processing { border-top-color: var(--orangina); }
.state.s-ok         { border-top-color: var(--golf); }
.state.s-fail       { border-top-color: var(--coral); }
```

### Outcome cards

```css
.outcomes {
  display: grid; grid-template-columns: repeat(3, 1fr);
  gap: var(--u3); margin: var(--u5) 0;
}
@media (max-width: 720px) { .outcomes { grid-template-columns: 1fr; } }
.outcome {
  background: var(--panel);
  border: 1px solid var(--border);
  border-radius: var(--r-md);
  padding: var(--u4) var(--u5);
  border-top: 3px solid var(--gunmetal-3);
}
.outcome h4 {
  margin: 0 0 var(--u2); font-size: 13px;
  font-family: var(--mono);
  text-transform: uppercase; letter-spacing: 0.06em;
  font-weight: 600;
}
.outcome p { font-size: 13.5px; color: var(--gunmetal-1); margin: 0 0 var(--u2); }
.outcome code { font-size: 12px; }
.outcome.is-cached { border-top-color: var(--golf); }
.outcome.is-cached h4 { color: var(--golf-deep); }
.outcome.is-attrs  { border-top-color: var(--orangina); }
.outcome.is-attrs h4 { color: var(--orangina-deep); }
.outcome.is-new    { border-top-color: var(--verbena-deep); }
.outcome.is-new h4 { color: var(--verbena-deep); }
```

### Budget / data table with bars

```css
.budget-table {
  width: 100%; border-collapse: collapse;
  margin: var(--u4) 0;
  background: var(--panel);
  border: 1px solid var(--border);
  border-radius: var(--r-md);
  overflow: hidden; font-size: 13.5px;
}
.budget-table th, .budget-table td {
  padding: var(--u2) var(--u4);
  text-align: left;
  border-bottom: 1px solid var(--gunmetal-5);
}
.budget-table th {
  background: var(--gunmetal-6);
  font-size: 11px; text-transform: uppercase;
  letter-spacing: 0.06em; color: var(--muted); font-weight: 600;
}
.budget-table tbody tr:last-child td { border-bottom: 0; }
.budget-table tbody tr.drop td {
  background: var(--coral-light);
  color: var(--coral); font-weight: 500;
}
.budget-table .bar-cell { width: 40%; }
.budget-table .bar {
  height: 8px;
  background: var(--layer-soft);
  border-radius: var(--r-pill);
  position: relative;
}
.budget-table .bar > span {
  display: block; height: 100%;
  background: var(--layer-accent);
  border-radius: var(--r-pill);
}
.budget-table .mono { font-family: var(--mono); color: var(--gunmetal-1); }
```

### File reference list

```css
.ref-list {
  background: var(--panel);
  border: 1px solid var(--border);
  border-radius: var(--r-md);
  padding: var(--u4) var(--u5);
  margin: var(--u4) 0;
  font-family: var(--mono); font-size: 12.5px;
  color: var(--gunmetal-1);
}
.ref-list .ref-title {
  font-family: var(--sans); font-size: 12px;
  text-transform: uppercase; letter-spacing: 0.06em;
  color: var(--muted); margin-bottom: var(--u2);
  font-weight: 600;
}
.ref-list ul { margin: 0; padding-left: var(--u4); }
.ref-list li { margin: 2px 0; }
.ref-list a {
  color: var(--text);
  text-decoration: none;
  border-bottom: 1px solid color-mix(in srgb, var(--layer-accent) 30%, transparent);
  transition: border-color 0.15s, color 0.15s;
}
.ref-list a:hover {
  color: var(--layer-deep);
  border-bottom-color: var(--layer-accent);
}
.ref-list .ref-note { color: var(--muted); }

/* Inline citation — for paths/symbols mentioned in body prose */
a.cite {
  color: var(--layer-deep);
  text-decoration: none;
  border-bottom: 1px dotted color-mix(in srgb, var(--layer-accent) 50%, var(--gunmetal-3));
  transition: border-bottom-style 0.1s, border-color 0.15s;
}
a.cite:hover {
  border-bottom-style: solid;
  border-color: var(--layer-accent);
}
a.cite code { font-size: inherit; color: inherit; }
```

### Hero block

```css
.hero {
  position: relative;
  padding: var(--u14) var(--u10) var(--u16);
  border-radius: var(--r-2xl);
  background: radial-gradient(
      ellipse 600px 400px at 85% 20%,
      color-mix(in srgb, var(--layer-accent) 9%, transparent),
      transparent 70%
    ),
    linear-gradient(180deg, var(--layer-tint), var(--panel));
  border: 1px solid color-mix(in srgb, var(--layer-accent) 14%, var(--border));
  box-shadow: var(--shadow-md);
  overflow: hidden;
  margin-bottom: var(--u20);
}
.hero::before {
  content: '';
  position: absolute; inset: 0;
  background-image:
    linear-gradient(90deg, color-mix(in srgb, var(--layer-accent) 8%, transparent) 1px, transparent 1px),
    linear-gradient(0deg, color-mix(in srgb, var(--layer-accent) 8%, transparent) 1px, transparent 1px);
  background-size: 56px 56px;
  mask-image: linear-gradient(135deg, black 0%, transparent 60%);
  -webkit-mask-image: linear-gradient(135deg, black 0%, transparent 60%);
  pointer-events: none;
}
.hero > * { position: relative; z-index: 1; }
.hero h1 { max-width: 14ch; margin-bottom: var(--u8); }
.hero h1 .accent { color: var(--layer-deep); font-style: italic; font-weight: 700; }
.hero .lede { margin-bottom: var(--u10); }
.hero-meta {
  display: flex; gap: var(--u8); flex-wrap: wrap;
  font-family: var(--mono); font-size: 11px;
  letter-spacing: 0.1em; text-transform: uppercase; color: var(--muted);
  border-top: 1px solid color-mix(in srgb, var(--layer-accent) 15%, var(--gunmetal-4));
  padding-top: var(--u5);
}
.hero-meta > div { display: flex; flex-direction: column; gap: 2px; }
.hero-meta b { color: var(--text); font-weight: 700; letter-spacing: 0.06em; }
```

### Chapter card

```css
.chapter-card {
  position: relative;
  padding: var(--u10) var(--u10) var(--u8);
  border-radius: var(--r-xl);
  background: linear-gradient(180deg, var(--layer-tint), var(--panel));
  border: 1px solid color-mix(in srgb, var(--layer-accent) 18%, var(--border));
  box-shadow: var(--shadow-sm);
  margin-bottom: var(--u10);
  overflow: hidden;
}
.chapter-card::after {
  content: ''; position: absolute; top: 0; left: 0; right: 0; height: 4px;
  background: linear-gradient(90deg,
    var(--layer-accent),
    color-mix(in srgb, var(--layer-accent) 60%, var(--layer-deep)));
}
.chapter-card .chapter-num {
  position: absolute; top: var(--u6); right: var(--u8);
  font-family: var(--mono); font-size: 11px;
  letter-spacing: 0.22em; text-transform: uppercase;
  color: var(--layer-accent); font-weight: 700;
}
.chapter-card h2 {
  font-size: 36px; font-weight: 700;
  letter-spacing: -1px; line-height: 1.05;
  margin: 0 0 var(--u4);
}
.chapter-card .chapter-lede {
  font-size: 18px; color: var(--gunmetal-1);
  margin: 0; line-height: 1.55;
}
@media (max-width: 900px) {
  .chapter-card { padding: var(--u8) var(--u6); }
  .chapter-card h2 { font-size: 28px; }
}
```

### Publication-style TOC brand

```css
.toc-brand {
  display: flex; flex-direction: column;
  gap: 4px; margin-bottom: var(--u3);
}
.toc-brand .pub {
  font-family: var(--mono); font-size: 10px; font-weight: 500;
  text-transform: uppercase; letter-spacing: 0.22em;
  color: var(--muted);
}
.toc-brand .title {
  font-family: var(--sans); font-weight: 700;
  font-size: 22px; letter-spacing: -0.4px;
  color: var(--text); line-height: 1;
}
.toc-brand .slash {
  color: var(--pool); font-weight: 600; margin-right: 4px;
}
.toc-meta {
  font-family: var(--mono); font-size: 10px;
  text-transform: uppercase; letter-spacing: 0.18em;
  color: var(--muted); margin-bottom: var(--u6);
}
```

### Site footer

```css
.site-footer {
  margin-top: var(--u20);
  padding: var(--u10) 0 var(--u4);
  border-top: 1px solid var(--border);
  display: flex; flex-direction: column;
  align-items: center; gap: var(--u3);
  text-align: center;
}
.site-footer .foot-mark {
  font-family: var(--sans); font-weight: 700;
  font-size: 15px; letter-spacing: -0.2px;
  color: var(--text);
}
.site-footer .foot-mark .slash {
  color: var(--pool); font-weight: 600; margin-right: 4px;
}
.site-footer .foot-flavor {
  font-family: var(--mono); font-size: 10px;
  text-transform: uppercase; letter-spacing: 0.22em;
  color: var(--muted);
}
.badger-trigger {
  background: transparent; border: 0; cursor: pointer;
  font-size: inherit; padding: 0 4px;
}
```

