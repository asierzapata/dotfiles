# Navigation Patterns

A catalog of ways the reader moves through the page. Pick one per explainer. The shape of the material decides which fits.

## How to Pick

| Material shape | Try |
| --- | --- |
| Sequential build-up, each concept depends on the last | Tabbed sections, slide-by-slide |
| One continuous narrative | Long-form scroll with sticky TOC |
| Independent parts of a whole, no required order | Hub-and-spoke, accordion |
| Reference-style, reader jumps around | Sticky TOC sidebar |
| Short page, two or three concepts | No nav, just scroll |

Don't combine patterns. One way to move through the page. If the material doesn't fit any of these, invent one in the same visual style.

---

## 1. Tabbed Sections

**Best for:** sequential build-up where each section adds one capability or framing shift, and the reader benefits from a "you are here" indicator.

**Behavior:** sticky pill nav at the top. Clicking a pill swaps the visible section. Only one section shows at a time. Scroll position resets on switch.

```html
<header>
  <div class="header-inner">
    <div class="brand">Topic<span class="dot">.</span></div>
    <nav id="section-nav">
      <button data-section="1" class="active"><span class="idx">01</span>Name</button>
      <button data-section="2"><span class="idx">02</span>Name</button>
      <button data-section="3"><span class="idx">03</span>Name</button>
    </nav>
  </div>
</header>
<main>
  <section class="tab-section active" data-section="1" data-accent="pool">...</section>
  <section class="tab-section" data-section="2" data-accent="orangina">...</section>
  <section class="tab-section" data-section="3" data-accent="verbena">...</section>
</main>
<script>
  const nav = document.getElementById('section-nav')
  const sections = document.querySelectorAll('main > section.tab-section')
  nav.addEventListener('click', e => {
    const btn = e.target.closest('button[data-section]')
    if (!btn) return
    const id = btn.dataset.section
    document.body.dataset.accent = btn.parentElement.querySelector(`[data-section="${id}"]`)?.dataset.accent || ''
    nav.querySelectorAll('button').forEach(b => b.classList.toggle('active', b.dataset.section === id))
    sections.forEach(s => {
      s.classList.toggle('active', s.dataset.section === id)
      document.body.dataset.accent = s.classList.contains('active') ? (s.dataset.accent || '') : document.body.dataset.accent
    })
    window.scrollTo({ top: 0, behavior: 'instant' })
  })
</script>
<style>
  .tab-section { display: none; }
  .tab-section.active { display: block; }
</style>
```

When to skip: if the sections don't really depend on each other, tabs hide content the reader should be able to scan in one view.

---

## 2. Long-form Scroll with Sticky TOC

**Best for:** one continuous narrative the reader should read top-to-bottom, but with enough length that a "where am I" anchor helps.

**Behavior:** all sections rendered in one document. A sidebar (or top bar) of anchor links sticks to the viewport. Clicking jumps with smooth scroll. The active item highlights as the reader scrolls past it.

**Responsive behavior:** at ≤ 900px the sidebar collapses into a sticky horizontal pill-strip at the top of the page (frosted-glass background, horizontally-scrollable chapter pills, nested children hidden — the chapter cards themselves serve as in-page sub-nav). At ≤ 600px the strip tightens further. The CSS below includes both breakpoints. The same JS continues to drive the active-item toggle, so the active pill highlights as the reader scrolls.

```html
<div class="layout-with-toc">
  <aside class="toc">
    <div class="toc-title">On this page</div>
    <ul>
      <li><a href="#s1" class="active">First concept</a></li>
      <li><a href="#s2">Second concept</a></li>
      <li><a href="#s3">Third concept</a></li>
    </ul>
  </aside>
  <main>
    <section id="s1" data-accent="pool">...</section>
    <section id="s2" data-accent="orangina">...</section>
    <section id="s3" data-accent="verbena">...</section>
  </main>
</div>
<style>
  .layout-with-toc { display: grid; grid-template-columns: 220px 1fr; gap: var(--u10); max-width: 1180px; margin: 0 auto; padding: var(--u10) var(--u6); }
  .toc { position: sticky; top: var(--u6); align-self: start; font-size: 13px; }
  .toc-title { font-family: var(--mono); font-size: 11px; text-transform: uppercase; letter-spacing: 0.08em; color: var(--muted); margin-bottom: var(--u3); }
  .toc ul { list-style: none; margin: 0; padding: 0; border-left: 1px solid var(--border); }
  .toc a { display: block; padding: var(--u2) var(--u3); color: var(--muted); text-decoration: none; border-left: 2px solid transparent; margin-left: -1px; }
  .toc a:hover { color: var(--text); }
  .toc a.active { color: var(--layer-accent, var(--accent)); border-left-color: var(--layer-accent, var(--accent)); }
  html { scroll-behavior: smooth; }
  main > section { scroll-margin-top: var(--u6); margin-bottom: var(--u16); }

  /* Mobile: TOC collapses into a sticky horizontal pill-strip at the top.
     Nested children (if any) are hidden — chapter cards serve as in-page sub-nav. */
  @media (max-width: 900px) {
    .layout-with-toc {
      grid-template-columns: 1fr;
      gap: 0;
      padding: 0 var(--u5) var(--u12);
      max-width: 100%;
    }
    .toc {
      position: sticky; top: 0; z-index: 20;
      max-height: none; overflow: visible;
      margin: 0 calc(var(--u5) * -1) var(--u6);
      padding: var(--u3) var(--u5);
      background: color-mix(in srgb, var(--bg) 92%, transparent);
      backdrop-filter: saturate(140%) blur(10px);
      -webkit-backdrop-filter: saturate(140%) blur(10px);
      border-bottom: 1px solid var(--border);
      display: flex; align-items: center; gap: var(--u4);
    }
    .toc-title { display: none; }
    .toc ul {
      border-left: 0;
      display: flex; flex-wrap: nowrap; gap: var(--u1);
      overflow-x: auto; overflow-y: hidden;
      scrollbar-width: none; -webkit-overflow-scrolling: touch;
      flex: 1; min-width: 0;
    }
    .toc ul::-webkit-scrollbar { display: none; }
    .toc li { flex-shrink: 0; }
    .toc a {
      padding: var(--u2) var(--u3);
      border-left: 0; border-radius: var(--r-pill);
      white-space: nowrap; margin-left: 0;
    }
    .toc a.active {
      background: var(--layer-soft, var(--accent-soft));
      color: var(--layer-deep, var(--accent-deep));
      border-left: 0;
    }
    /* If the TOC has nested children, hide them — top-level only on mobile */
    .toc-children { display: none !important; }
  }

  @media (max-width: 600px) {
    .layout-with-toc { padding: 0 var(--u4) var(--u10); }
    .toc {
      margin: 0 calc(var(--u4) * -1) var(--u4);
      padding: var(--u2) var(--u4); gap: var(--u2);
    }
  }
</style>
<script>
  const links = document.querySelectorAll('.toc a')
  const targets = [...links].map(a => document.querySelector(a.getAttribute('href')))
  const observer = new IntersectionObserver(entries => {
    entries.forEach(en => {
      if (!en.isIntersecting) return
      const i = targets.indexOf(en.target)
      links.forEach((a, k) => a.classList.toggle('active', k === i))
      document.body.dataset.accent = en.target.dataset.accent || ''
    })
  }, { rootMargin: '-30% 0px -60% 0px' })
  targets.forEach(t => t && observer.observe(t))
</script>
```

When to skip: short pages (under 3 sections). The TOC becomes overhead with no payoff.

---

## 3. Slide-by-Slide

**Best for:** strongly linear teaching, one idea per screen, where the pace of the reveal matters. Closer to a presentation than a document.

**Behavior:** one slide visible at a time. Prev / next buttons (or arrow keys) advance. A counter or progress dots show position.

```html
<div class="deck" id="deck">
  <div class="deck-slide active" data-accent="pool">...</div>
  <div class="deck-slide" data-accent="orangina">...</div>
  <div class="deck-slide" data-accent="verbena">...</div>
  <div class="deck-controls">
    <button class="deck-prev">← prev</button>
    <div class="deck-dots"></div>
    <button class="deck-next">next →</button>
  </div>
</div>
<style>
  .deck { max-width: 880px; margin: 0 auto; padding: var(--u10) var(--u6); }
  .deck-slide { display: none; min-height: 60vh; }
  .deck-slide.active { display: block; }
  .deck-controls { display: flex; align-items: center; justify-content: space-between; gap: var(--u4); margin-top: var(--u10); border-top: 1px solid var(--border); padding-top: var(--u4); }
  .deck-controls button { background: var(--panel); border: 1px solid var(--border); border-radius: var(--r-pill); padding: var(--u2) var(--u4); font-family: inherit; font-size: 13px; cursor: pointer; }
  .deck-controls button:hover { background: var(--gunmetal-5); }
  .deck-dots { display: flex; gap: var(--u2); }
  .deck-dots span { width: 8px; height: 8px; border-radius: 50%; background: var(--gunmetal-4); }
  .deck-dots span.active { background: var(--layer-accent, var(--accent)); }
</style>
<script>
  const deck = document.getElementById('deck')
  const slides = deck.querySelectorAll('.deck-slide')
  const dotsEl = deck.querySelector('.deck-dots')
  let i = 0
  slides.forEach(() => dotsEl.appendChild(document.createElement('span')))
  const render = () => {
    slides.forEach((s, k) => s.classList.toggle('active', k === i))
    dotsEl.querySelectorAll('span').forEach((d, k) => d.classList.toggle('active', k === i))
    document.body.dataset.accent = slides[i].dataset.accent || ''
  }
  deck.querySelector('.deck-prev').onclick = () => { i = Math.max(0, i - 1); render() }
  deck.querySelector('.deck-next').onclick = () => { i = Math.min(slides.length - 1, i + 1); render() }
  window.addEventListener('keydown', e => {
    if (e.key === 'ArrowLeft') deck.querySelector('.deck-prev').click()
    if (e.key === 'ArrowRight') deck.querySelector('.deck-next').click()
  })
  render()
</script>
```

When to skip: dense reference content. Slide-by-slide forces pace; reference readers want to scan.

---

## 4. Accordion

**Best for:** independent sections the reader picks from, especially when content length varies a lot. Lets the reader collapse what they don't need.

**Behavior:** each section has a header that toggles open/closed. Multiple can be open at once. State is local to each section.

```html
<div class="accordion">
  <details class="acc-item" data-accent="pool" open>
    <summary><span class="acc-idx">01</span>First concept<span class="acc-chev">▾</span></summary>
    <div class="acc-body">...</div>
  </details>
  <details class="acc-item" data-accent="orangina">
    <summary><span class="acc-idx">02</span>Second concept<span class="acc-chev">▾</span></summary>
    <div class="acc-body">...</div>
  </details>
</div>
<style>
  .accordion { max-width: 880px; margin: 0 auto; padding: var(--u10) var(--u6); display: grid; gap: var(--u3); }
  .acc-item { background: var(--panel); border: 1px solid var(--border); border-radius: var(--r-md); overflow: hidden; }
  .acc-item summary { list-style: none; display: flex; align-items: center; gap: var(--u3); padding: var(--u4) var(--u5); cursor: pointer; font-weight: 600; }
  .acc-item summary::-webkit-details-marker { display: none; }
  .acc-idx { font-family: var(--mono); font-size: 11px; color: var(--muted); }
  .acc-chev { margin-left: auto; color: var(--muted); transition: transform 0.2s; }
  .acc-item[open] .acc-chev { transform: rotate(180deg); }
  .acc-item[open] summary { color: var(--layer-accent, var(--accent)); }
  .acc-body { padding: 0 var(--u5) var(--u5); }
</style>
<script>
  document.querySelectorAll('.acc-item').forEach(item => {
    item.addEventListener('toggle', () => {
      if (item.open) document.body.dataset.accent = item.dataset.accent || ''
    })
  })
</script>
```

When to skip: sequential material. Hiding step 2 behind a click breaks the build-up.

---

## 5. Hub-and-Spoke

**Best for:** an overview that branches into independent deep-dives. The reader picks a spoke, reads it, comes back to the hub.

**Behavior:** a landing view shows a grid of cards (the spokes). Clicking one opens that spoke as a full section with a "back to overview" link.

```html
<main class="hub-main">
  <section class="hub-view active" id="hub">
    <h1>Topic</h1>
    <p class="lede">Short intro framing the whole.</p>
    <div class="spokes">
      <a class="spoke" data-spoke="a" data-accent="pool">
        <div class="spoke-idx">A</div>
        <div class="spoke-title">First area</div>
        <div class="spoke-sub">One-line description.</div>
      </a>
      <a class="spoke" data-spoke="b" data-accent="orangina">
        <div class="spoke-idx">B</div>
        <div class="spoke-title">Second area</div>
        <div class="spoke-sub">One-line description.</div>
      </a>
      <a class="spoke" data-spoke="c" data-accent="verbena">
        <div class="spoke-idx">C</div>
        <div class="spoke-title">Third area</div>
        <div class="spoke-sub">One-line description.</div>
      </a>
    </div>
  </section>
  <section class="spoke-view" id="spoke-a" data-accent="pool">
    <a class="back" href="#hub">← back to overview</a>
    <h1>First area</h1>
    ...
  </section>
  <section class="spoke-view" id="spoke-b" data-accent="orangina">...</section>
  <section class="spoke-view" id="spoke-c" data-accent="verbena">...</section>
</main>
<style>
  .hub-main { max-width: 1120px; margin: 0 auto; padding: var(--u10) var(--u6); }
  .hub-view, .spoke-view { display: none; }
  .hub-view.active, .spoke-view.active { display: block; }
  .spokes { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: var(--u4); margin-top: var(--u8); }
  .spoke { display: block; background: var(--panel); border: 1px solid var(--border); border-radius: var(--r-lg); padding: var(--u5); text-decoration: none; color: var(--text); transition: border-color 0.15s, transform 0.15s; cursor: pointer; }
  .spoke:hover { border-color: var(--layer-accent, var(--accent)); transform: translateY(-2px); }
  .spoke-idx { font-family: var(--mono); font-size: 12px; color: var(--muted); }
  .spoke-title { font-size: 18px; font-weight: 600; margin: var(--u2) 0; }
  .spoke-sub { font-size: 13px; color: var(--muted); }
  .back { display: inline-block; font-family: var(--mono); font-size: 12px; color: var(--muted); text-decoration: none; margin-bottom: var(--u5); }
  .back:hover { color: var(--text); }
</style>
<script>
  const views = document.querySelectorAll('.hub-view, .spoke-view')
  const show = id => {
    views.forEach(v => v.classList.toggle('active', v.id === id))
    const v = document.getElementById(id)
    document.body.dataset.accent = v?.dataset.accent || ''
    window.scrollTo({ top: 0, behavior: 'instant' })
  }
  document.querySelectorAll('.spoke').forEach(s => s.onclick = e => { e.preventDefault(); show('spoke-' + s.dataset.spoke) })
  document.querySelectorAll('.back').forEach(a => a.onclick = e => { e.preventDefault(); show('hub') })
  show('hub')
</script>
```

When to skip: when the spokes are short. The round-trip feels heavier than the content warrants.

---

## 6. No Nav (Single Scroll)

**Best for:** short pages with two or three concepts. A nav adds chrome for no payoff.

**Behavior:** one document, no nav, reader scrolls. Sections separated by spacing and a horizontal rule or accent shift. Optionally a brand bar at top with the title only.

```html
<header class="bar"><div class="brand">Topic<span class="dot">.</span></div></header>
<main class="single">
  <section data-accent="pool">...</section>
  <hr class="sep" />
  <section data-accent="orangina">...</section>
</main>
<style>
  .bar { padding: var(--u4) var(--u6); border-bottom: 1px solid var(--border); }
  .single { max-width: 880px; margin: 0 auto; padding: var(--u10) var(--u6); }
  .single > section { margin-bottom: var(--u12); }
  .sep { border: 0; border-top: 1px solid var(--border); margin: var(--u10) 0; }
</style>
<script>
  const ss = document.querySelectorAll('.single > section[data-accent]')
  const io = new IntersectionObserver(es => es.forEach(e => e.isIntersecting && (document.body.dataset.accent = e.target.dataset.accent)), { rootMargin: '-30% 0px -60% 0px' })
  ss.forEach(s => io.observe(s))
</script>
```

When to skip: anything over ~5 sections. Readers lose place without an anchor.

---

## Anti-Patterns

- **Combining two navigation systems.** Pick one. A page with both tabs and a sticky TOC has two ways to navigate and zero good ones.
- **Tabs for content that benefits from peripheral vision.** If the reader needs to compare section A and section C, don't hide them behind clicks.
- **Sticky TOC on a short page.** The TOC weighs more than the content.
- **Slide-by-slide for reference content.** Forcing pace on a reader who wants to scan is hostile.
- **Hub-and-spoke where the hub is empty.** If the overview has nothing to say, just list the sections in a single scroll.

