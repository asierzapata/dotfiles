---
name: html-explainer
description: Translate a source document or concept into a single-page HTML explainer using a shared visual language, a catalog of visualizations, and a catalog of navigation patterns. Use when the user wants to turn a brief, RFC, doc, or rough explanation into a self-contained interactive HTML page. The skill provides building blocks (style, visualizations, navigation) without enforcing a specific structure on the output.
---

# HTML Explainer Builder

Turns a source document or concept description into a self-contained HTML page. The skill is intentionally unopinionated about the page's structure: it gives you a shared **visual language**, a catalog of **visualization patterns**, and a catalog of **navigation patterns**. You pick what fits the material.

## What this skill provides

- **A consistent visual style.** Design tokens (palette, spacing, typography, radii, shadows) and a component library (diagrams, callouts, code blocks, state cards, tables, ref lists). Every explainer built with this skill should look like it belongs in the same family. See [BASE_TEMPLATE.html](./BASE_TEMPLATE.html) and [REFERENCE.md](./REFERENCE.md).
- **A catalog of visualizations.** Patterns for teaching state, change, flow, comparison, quantity, sequence, hierarchy. See [VISUALIZATION_PATTERNS.md](./VISUALIZATION_PATTERNS.md).
- **A catalog of navigation patterns.** Different ways the reader moves through the page (tabbed sections, long-form scroll, sticky TOC, accordion, slide-by-slide, hub-and-spoke). See [NAVIGATION_PATTERNS.md](./NAVIGATION_PATTERNS.md).
- **A writing style guide.** Voice, tone, anti-AI cadence rules. See [writing-style.md](~/.claude/writing-style.md).

## What this skill does NOT do

- Force a specific number of sections, "layers", or any one structural pattern.
- Pick the visualization or navigation for you. Those choices come from the material.
- Replace a build step. Output is vanilla HTML/CSS/JS, one file, no dependencies.
- Substitute for documentation in a repo (use `architecture-doc` for that).

## When to use

- The user has a source document, brief, RFC, or rough explanation and wants an HTML page that teaches the same content.
- The user wants a shareable single-page explainer of a technical concept.
- The user wants to mix prose with interactive diagrams, in the Edpuzzle visual style.

## Workflow

The workflow has four moves: **read the source**, **pick visualizations**, **pick a navigation**, **assemble**. The order matters because navigation depends on what the visualizations want to be.

### 1. Read the source material

The best input is a **hand-written markdown source** in the user's own voice, with real prose, real code, and opinionated framing. If the user has one (or wants to write one), use it directly — don't reach for `explainer-research` first. A structural brief tends to be too generic to drive a great explainer; a real document already carries the voice and stakes the explainer needs to amplify.

**Treat the source markdown as authoritative prose, not as a brief to paraphrase.** The hand-written text is high-quality; rewording it for "explainer voice" degrades it. The explainer's job is to wrap that prose in visuals and chrome, not to rewrite it. See step 4c for the verbatim-first rule.

If the user provided a document, brief, or set of files, read them and extract:

- The **concepts** the page needs to teach (each is a candidate for its own section).
- For each concept, the **lesson** the reader should walk away with.
- Any **real code or file paths** that should be cited.
- The **shape of the material**: is it sequential (build-up), parallel (alternatives), hierarchical (parts of a whole), exploratory (no single path)?
- The **voice and opinions** already in the source. Preserve them. The explainer should sound like the markdown, only with visuals.

Write this down before opening an editor. A short outline is enough: concept → lesson → candidate visualization.

If documentation in the repo is authoritative for the topic, read it. Verify defaults and behaviors against current code (docs go stale).

### 2. Pick visualizations with the user

Visualization choice is collaborative. Don't pick alone, don't ask blank-slate.

For each concept, propose a **recommended visualization** plus one or two alternatives from [VISUALIZATION_PATTERNS.md](./VISUALIZATION_PATTERNS.md). Present them as a short list: concept → recommendation (one-line why) → alternatives → "prose-only" as a valid option. The user picks. Only proceed once the choices are confirmed.

Guidelines when recommending:

- Default recommendation is prose unless a visualization clearly earns its place.
- Match the pattern to the shape of the lesson (state → state machine, quantity → bars/sparkline, sequence → autoplay/scrubber, comparison → before/after, parallel work → swim-lanes).
- Vary the patterns across the page. A page of scrubbers feels like a calculator. If three concepts all pull toward the same pattern, recommend different ones for two of them.
- Aim for at least one non-static element per major section (animation, toggle, scrubber, hover-reveal, click-to-advance). Flag this in the recommendation when a section would otherwise be fully static.

Record the agreed picks before writing. The user can also invent new patterns; if so, capture them in the same visual style as the catalog.

### 3. Pick a navigation pattern

The shape of the material tells you which navigation fits:

- **Sequential build-up** (each concept depends on the last) → tabbed sections or slide-by-slide.
- **Long narrative** (one continuous argument) → long-form scroll with sticky TOC or section nav.
- **Independent parts of a whole** (no required order) → hub-and-spoke or accordion.
- **Reference-style** (reader jumps around) → sticky TOC sidebar.

The catalog of navigation patterns lives in [NAVIGATION_PATTERNS.md](./NAVIGATION_PATTERNS.md). Each entry has the HTML, CSS, and JS to drop in, plus notes on when it fits.

Don't combine navigation patterns. Pick one. The page should have a single way to move through it.

### 4. Assemble

**Before writing CSS, read the "Aesthetic direction" section below.** Commit to the direction explicitly. The page chrome and components only land well when the model is intentionally executing an aesthetic, not picking defaults.

Start from [BASE_TEMPLATE.html](./BASE_TEMPLATE.html). It contains the design tokens, typography, and the component CSS, but no navigation and no enforced section structure.

This is where iteration costs the most. Work in the order below — it's deliberately page-chrome first, then per-section visualizations, then prose, then polish. Skipping the chrome and writing prose first produces a page that has to be retrofitted later, which is the most expensive kind of edit.

#### 4a. Page chrome first

Drop in the four scaffolding components from `REFERENCE.md` → "Page Chrome" before any section content exists:

1. **Hero block** — eyebrow, h1 with one or two accent words, lede, meta row.
2. **Chapter card** for each section — placeholder number, eyebrow, h2, one-sentence lede. (Write the leades last; placeholder is fine for now.)
3. **TOC brand** in the sidebar — `Edpuzzle / <Edition>`, "On this page", anchor list.
4. **Site footer** — mark + flavor line. The personality moment goes here (see below).

The chrome anchors the visual tone before a single visualization is in place. With this skeleton up, every later edit slots into a finished frame.

#### 4b. One major visualization per section

Each section gets exactly **one** featured visualization — the visualization for the lesson the chapter is named after. Pick from `VISUALIZATION_PATTERNS.md`; draft it as real SVG/CSS in the first pass, not as a stub. Retrofitting a real diagram into a section that was written around a stub is the back-and-forth that eats time. If a section's lesson doesn't earn a major visualization, leave it prose-only and don't force one.

Vary patterns across sections. A page of three scrubbers feels like a calculator. A page that uses a dual-mode diagram, a paired mini-replay, a sequence scrubber, and a timeline feels like an explainer.

#### 4c. Supporting prose, code, callouts — verbatim from the source

**Pull text verbatim from the source markdown wherever possible.** The hand-written prose is the highest-quality material on the page; paraphrasing it for "explainer voice" or "smoother transitions" loses the voice and the opinion. The explainer's job is to *frame* that prose, not rewrite it.

Rules:

- **Hero h1 and lede come from the source title and intro.** Don't invent a new headline. If the source title is too long for the hero, split it across the h1's `.accent` spans (e.g., italicize one or two key words from the original title).
- **Chapter ledes come from the section's opening sentence in the source.** Trim if needed to fit one line; never replace with new prose.
- **Body paragraphs are copy-pasted from the source.** Edit only for the visual frame: shortening a long paragraph that has to become a callout, splitting one paragraph in two so a visualization can sit between them.
- **Code blocks use the exact snippets from the source.** Don't substitute "cleaner" examples. If the source's example is verbose, that's a deliberate choice the author made.
- **Callouts are pulled from the source's emphasized lines** (bolded sentences, rules-of-thumb, "**1. Does the flow have a business name?**"-style headers). Promote them into `.callout` blocks; don't write new ones.
- **Don't generate gap-filler prose around a visualization.** If a section needs supporting prose and the source doesn't have it, ask the user rather than inventing it. An honest "this concept needs one more paragraph from you" is better than a hallucinated one.
- **Cite files inline, generously, with real links.** When a sentence names a class, schema, or file, wrap that mention in an `<a class="cite">` linking to the file on GitHub. Don't just say "the Journal is validated by a zod schema in `journal.js`" — link `journal.js`. The same applies to documentation: when the source references `documentation/.../index.md`, that should be a link, not a path. A finished page has many inline citations, not one ref-list at the bottom. See [REFERENCE.md](./REFERENCE.md#file-reference-list) for the patterns.

Acceptable edits:
- Trimming for tight slots (chapter card lede, eyebrow, hero meta).
- Splitting a long source paragraph into two for layout.
- Promoting an inline emphasis into a callout block.
- Adjusting tense/voice consistency within a copied paragraph.

Not acceptable:
- Rewriting a paragraph in "smoother explainer voice".
- Generating an intro sentence to bridge sections.
- Substituting a "better" code example.
- Adding "as we discussed" or "now let's see" connective tissue.

Within a section, a useful order:

1. The chapter card (4a) — lede pulled from source's section intro.
2. The featured visualization (4b).
3. Source paragraphs, copied in order.
4. Code blocks from the source, where the source has them.
5. Callouts promoted from the source's emphasized lines.
6. A file reference block when the source cites code.

Work one section at a time. Edit, don't rewrite. Output token limits are real and the file grows fast.

#### 4d. Personality moment

Every explainer closes with the **standing badger footer**: a "Made by badgers" line and the badger easter egg trigger. This is the constant. Drop it in unchanged from the `REFERENCE.md` site-footer snippet. Don't reinvent it per page — continuity across the family is the point.

Optionally, layer **one extra personality moment** on top if the page earns it:
- A quote pulled from a real Slack thread or incident retro, used as a callout once on the page.
- A footnote with a one-liner about why this work happened.
- An animated mid-page detail that only fires on a specific interaction.

At most one extra. Don't pile them up — restraint is what makes a delight feel like a delight.

#### 4e. Polish

Most of the back-and-forth on a real explainer is in this phase: aligning a label inside an SVG, adjusting the curve of an edge, making a sequence diagram's lifelines stop before the arrowhead, tuning a `min-height` so a card doesn't jump when its text changes. Budget for it.

If the user gives feedback like "this diagram doesn't quite read right", treat the visualization, not the prose, as the thing to change first. The prose usually survives polish; the visualization is what gets iterated on.

## The section accent system

Every section can opt into an **accent color** that cascades through eyebrow, callouts, code highlights, bar fills, and any node marked as the "protagonist" of the section. The accent is set via `data-accent="..."` on the section (or on `<body>` for global). The available accents are `pool`, `orangina`, `verbena`, `golf`, `coral`, `bananas`. See [REFERENCE.md](./REFERENCE.md#section-accent-system).

The accent system is **optional**, not required. A monochrome page is fine. If the material has a natural color logic (e.g., warning vs success vs neutral, or distinct sub-systems), use it; otherwise skip it.

## Aesthetic direction

Before writing CSS, commit to the aesthetic direction explicitly. Without that commitment, the page drifts toward the default "AI technical doc" look — Inter-on-white, neutral-grey cards, evenly distributed palette, predictable hover states — which is exactly what makes generic AI-generated frontends look generic.

**The Edpuzzle explainer aesthetic is: editorial publication + technical blueprint.** Concretely:

- **Editorial voice in the chrome.** Publication-style masthead (`Edpuzzle / Engineering`), chapter numbering (`Ch. 01`), eyebrow labels in mono-uppercase with wide tracking, a hero that reads like a long-form article opener with a meta row (read time, presenters, date). The reader should feel they're holding an issue of something, not a help article.
- **Technical blueprint in the visuals.** A subtle dot-grid background in the hero, mono captions on diagrams, accent strokes on chapter cards, SVG diagrams with labeled flow lines and small mono annotations. The diagrams should look engineered, not decorative.
- **Accent-driven, not evenly-distributed.** Each section commits to one accent from the palette (`pool / orangina / verbena / golf / coral / bananas`). The accent cascades through eyebrow, callouts, code highlights, and protagonist nodes. A muted page where every section uses the same neutral grey is failure mode — readers learn the color code and use it to navigate.
- **Typography pair: GT Pressura + system mono.** GT Pressura carries the personality; mono carries the structure (labels, eyebrows, code, captions). Mono-uppercase with wide letter-spacing is the explainer's signature treatment for labels — use it generously.
- **One orchestrated load, not scattered micro-interactions.** Hover states and replay buttons earn their place by teaching. Avoid sparkle-for-sparkle's-sake.
- **A personality moment.** Every page gets one (see step 4d). Without it, the page reads like documentation, not an explainer.

**Variation within the direction.** Pick a *dominant accent* per page that signals the topic's character (e.g., `pool` for foundational/architectural, `verbena` for new tooling, `orangina` for risk/constraints). Vary the hero's accent shading, the meta row's content, the personality moment. Don't vary the masthead style, the chapter card format, or the typography pair — those are the constants that make the family.

### Avoid these AI defaults

- **Inter / Roboto / system-ui as the body font.** GT Pressura is the brand. Don't fall back to generic sans-serifs.
- **Purple-to-pink gradients on white.** The palette has six accents; use them. No invented hexes, no gradient meshes outside the established `--layer-tint` and accent-mix patterns.
- **Card-on-card-on-card grids.** A page that's all uniform white cards in a 3-column grid is the AI tell. The chapter card is a deliberate frame; everything else should vary in shape, density, and weight.
- **Evenly distributed palettes.** Pick one dominant accent per section and let it carry; don't sprinkle six colors equally across the page.
- **Decorative motion.** Pulsing dots, drifting gradients, parallax-on-scroll that don't teach. Every animation answers "what lesson does this carry?"
- **Soft pastel everything.** The palette has saturated accents (`--pool`, `--coral`, `--orangina`) for a reason. Use them at full strength on protagonist elements.
- **Predictable corner radius / shadow combos.** The design tokens define a hierarchy (`--r-sm` through `--r-pill`, `--shadow-sm` / `--shadow-md`). Use the right one for the role; don't default every card to `border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1)`.

## Design principles

- **Light theme, soymilk background.** Match the Edpuzzle product, not a dark IDE.
- **One file, no dependencies.** Vanilla HTML/CSS/JS. Should drop into any static host and work.
- **Real references when present.** If the source cites code, include the file paths. If not, don't invent them.
- **Honest visualizations.** Faithful charts beat dramatic ones. Log scale when ranges span orders of magnitude.
- **Mobile is a courtesy, not a target.** Breakpoints exist so the page doesn't break on small screens, not so it shines there.
- **Hold the aesthetic direction.** When iterating, drift toward more committed, not more generic. If a section starts feeling like a help-doc card, push it back toward editorial.
- **Source prose is authoritative.** Pull text verbatim from the source markdown. Don't paraphrase, don't smooth transitions, don't generate gap-filler. If the source is missing prose a section needs, ask the user.
- **Cite generously, always with links.** Every file or doc named in the prose gets an inline `<a class="cite">` to its location on GitHub. Bare paths in body text are a failure mode. Every section closes with a linked `ref-list` of the files that back it.
- **The badger footer is a constant.** "Made by badgers" + badger easter egg is the standing closing for every explainer in the family. Don't reinvent it per page; layer extra personality moments on top if the page calls for them.

## Reference files

- [BASE_TEMPLATE.html](./BASE_TEMPLATE.html) — design tokens, typography, component CSS. No nav, no enforced structure.
- [REFERENCE.md](./REFERENCE.md) — design tokens reference and component library (HTML snippets).
- [VISUALIZATION_PATTERNS.md](./VISUALIZATION_PATTERNS.md) — catalog of visualization patterns.
- [NAVIGATION_PATTERNS.md](./NAVIGATION_PATTERNS.md) — catalog of navigation patterns.
- [writing-style.md](~/.claude/writing-style.md) — voice, tone, anti-AI cadence rules.
