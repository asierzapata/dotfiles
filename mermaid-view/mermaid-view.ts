import { spawnSync } from 'node:child_process'
import { existsSync, mkdirSync, readFileSync, renameSync, watch, writeFileSync } from 'node:fs'
import { homedir } from 'node:os'
import { dirname, join, resolve } from 'node:path'
import { renderMermaidASCII, renderMermaidSVG, THEMES, type DiagramColors } from 'beautiful-mermaid'

type Mode = 'text' | 'image'
type Options = { mode: Mode; theme: string; title?: string }

const USAGE = `Render Mermaid diagrams with beautiful-mermaid and show them in a Rex pane.

Usage:
  mermaid-view [FILE|-] [--image] [--theme NAME] [--title TEXT]
      Show a diagram. Inside Rex, it opens a "Diagram" pane beside the
      current one, or redraws the one this session already has. Outside
      Rex, it prints the diagram here. Reads stdin when FILE is - or absent.
  mermaid-view render FILE [--format text|svg|png] [-o OUT] [--theme NAME]
      Render to a file, or to stdout for text and svg.
  mermaid-view close
      Close this session's Diagram pane.
  mermaid-view themes
      List the theme names.

Options:
  --image       Show a high-quality image instead of Unicode text.
  --theme NAME  Color theme (default: $MERMAID_VIEW_THEME or tokyo-night).
  --title TEXT  Heading shown above the diagram in the pane.

Supported diagrams: flowchart/graph, sequenceDiagram, stateDiagram-v2,
classDiagram, erDiagram, xychart-beta.`

const SCRIPT = new URL(import.meta.url).pathname
const CHROME =
  process.env.MERMAID_VIEW_CHROME ?? '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
const DEFAULT_THEME = process.env.MERMAID_VIEW_THEME ?? 'tokyo-night'

function fail(message: string): never {
  process.stderr.write(`mermaid-view: ${message}\n`)
  process.exit(1)
}

function parseArgs(argv: string[]) {
  const positional: string[] = []
  const flags: Record<string, string | boolean> = {}
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i]
    if (arg === '--image') flags.image = true
    else if (arg === '-h' || arg === '--help') flags.help = true
    else if (arg === '--theme' || arg === '--title' || arg === '--format' || arg === '-o') {
      const value = argv[++i]
      if (value === undefined) fail(`${arg} needs a value`)
      flags[arg.replace(/^-+/, '')] = value
    } else if (arg.startsWith('--')) fail(`unknown option ${arg}`)
    else positional.push(arg)
  }
  return { positional, flags }
}

function colors(theme: string): DiagramColors {
  const colors = THEMES[theme]
  if (!colors) fail(`unknown theme "${theme}". Run: mermaid-view themes`)
  return colors
}

function renderText(source: string, theme: string, colorMode: 'truecolor' | 'none' = 'truecolor') {
  const c = colors(theme)
  return renderMermaidASCII(source, {
    colorMode,
    theme: {
      fg: c.fg,
      bg: c.bg,
      border: c.border ?? c.muted ?? c.fg,
      line: c.line ?? c.muted ?? c.fg,
      arrow: c.accent ?? c.fg,
      accent: c.accent,
    },
  })
}

function renderSvg(source: string, theme: string) {
  return renderMermaidSVG(source, { ...colors(theme), font: 'Inter, -apple-system, Helvetica, sans-serif' })
}

// The SVG styles itself with CSS variables and color-mix(), which simple
// SVG rasterizers ignore, so a headless Chrome screenshot is the faithful way
// to get a PNG.
function renderPng(source: string, theme: string, out: string) {
  if (!existsSync(CHROME)) fail(`Chrome not found at ${CHROME}. Set MERMAID_VIEW_CHROME.`)
  const svg = renderSvg(source, theme)
  const size = svgSize(svg)
  const html = join(dirname(out), `${Date.now()}-${process.pid}.html`)
  writeFileSync(
    html,
    `<!doctype html><meta charset="utf-8"><style>html,body{margin:0;background:${colors(theme).bg}}svg{display:block}</style>${svg}`,
  )
  const result = spawnSync(
    CHROME,
    [
      '--headless=new',
      '--disable-gpu',
      '--hide-scrollbars',
      '--no-first-run',
      '--force-device-scale-factor=2',
      `--window-size=${size.width},${size.height}`,
      `--screenshot=${out}`,
      `file://${html}`,
    ],
    { encoding: 'utf8' },
  )
  spawnSync('rm', ['-f', html])
  if (result.status !== 0 || !existsSync(out)) fail(`Chrome failed to render the PNG\n${result.stderr}`)
}

function svgSize(svg: string) {
  const viewBox = svg.match(/viewBox="[\d.\s-]*?([\d.]+)\s+([\d.]+)"/)
  const width = Number(svg.match(/<svg[^>]*\swidth="([\d.]+)/)?.[1] ?? viewBox?.[1] ?? 1200)
  const height = Number(svg.match(/<svg[^>]*\sheight="([\d.]+)/)?.[1] ?? viewBox?.[2] ?? 800)
  return { width: Math.ceil(width), height: Math.ceil(height) }
}

function readSource(file?: string) {
  if (!file || file === '-') {
    if (process.stdin.isTTY) fail('no diagram given. Pass a file or pipe Mermaid text on stdin.')
    return readFileSync(0, 'utf8')
  }
  if (!existsSync(file)) fail(`file not found: ${file}`)
  return readFileSync(file, 'utf8')
}

function stateDir() {
  const session = process.env.REX_SESSION?.replace(/[^\w-]/g, '_') ?? 'default'
  const dir = join(process.env.XDG_CACHE_HOME ?? join(homedir(), '.cache'), 'mermaid-view', session)
  mkdirSync(dir, { recursive: true })
  return dir
}

function writeAtomic(path: string, content: string) {
  writeFileSync(`${path}.tmp`, content)
  renameSync(`${path}.tmp`, path)
}

function rex(args: string[]) {
  const result = spawnSync('rex', args, { encoding: 'utf8' })
  if (result.status !== 0) fail(`rex ${args[0]} failed: ${result.stderr.trim()}`)
  return result.stdout
}

function livePane(dir: string): string | undefined {
  const paneFile = join(dir, 'pane')
  if (!existsSync(paneFile)) return undefined
  const id = readFileSync(paneFile, 'utf8').trim()
  const { blocks } = JSON.parse(rex(['block', 'ls', '-s', process.env.REX_SESSION!, '--json']))
  return blocks.some((b: { block_id: string }) => b.block_id === id) ? id : undefined
}

function show(source: string, options: Options) {
  // Render once up front so an error reaches the caller instead of the pane.
  // The parser drops lines it cannot read without complaining, so an empty
  // result is the only sign that the whole body was invalid.
  let text: string
  try {
    text = renderText(source, options.theme, 'none')
  } catch (error) {
    fail(`could not render the diagram: ${(error as Error).message}`)
  }
  if (!text.trim()) fail('the diagram rendered empty. Check its syntax.')

  if (!process.env.REX_SESSION) {
    printDiagram(source, options, stateDir())
    return
  }

  const dir = stateDir()
  writeAtomic(join(dir, 'options.json'), JSON.stringify(options))
  writeAtomic(join(dir, 'diagram.mmd'), source)

  const existing = livePane(dir)
  if (existing) {
    console.log(`Updated the Diagram pane (${existing}).`)
    return
  }

  const anchor = process.env.REX_BLOCK ? ['-b', process.env.REX_BLOCK] : []
  const created = JSON.parse(
    rex([
      'split', '-s', process.env.REX_SESSION, ...anchor,
      '--split=right', '--ratio', '45', '--label', 'Diagram', '--focus=false', '--json',
      '--shell=none', '--', process.execPath, SCRIPT, 'watch', dir,
    ]),
  )
  const id = created.block_ids[0]
  writeAtomic(join(dir, 'pane'), id)
  console.log(`Opened a Diagram pane (${id}).`)
}

function printDiagram(source: string, options: Options, dir: string) {
  if (options.mode === 'text') {
    const text = renderText(source, options.theme)
    const width = Math.max(...renderText(source, options.theme, 'none').split('\n').map((l) => l.length))
    const columns = process.stdout.columns ?? Infinity
    if (width <= columns || !process.stdout.isTTY) {
      process.stdout.write(`${text}\n`)
      return
    }
    // Wrapped box drawing is unreadable, so a diagram wider than the pane is
    // shown as an image, which scales down to fit.
    process.stdout.write(`\x1b[2m${width} columns wide, pane has ${columns}: showing the image\x1b[0m\n\n`)
  }
  const png = join(dir, 'diagram.png')
  renderPng(source, options.theme, png)
  spawnSync('kitty', ['+kitten', 'icat', '--stdin=no', '--transfer-mode=stream', '--align=left', png], {
    stdio: 'inherit',
  })
}

function watchPane(dir: string) {
  let timer: ReturnType<typeof setTimeout> | undefined
  const draw = () => {
    // Clear the screen and scrollback, and delete images left by the last draw.
    process.stdout.write('\x1b[2J\x1b[3J\x1b[H\x1b_Ga=d\x1b\\')
    try {
      const source = readFileSync(join(dir, 'diagram.mmd'), 'utf8')
      const options: Options = JSON.parse(readFileSync(join(dir, 'options.json'), 'utf8'))
      const time = new Date().toLocaleTimeString()
      process.stdout.write(`\x1b[1m${options.title ?? 'Diagram'}\x1b[0m  \x1b[2m${time}\x1b[0m\n\n`)
      printDiagram(source, options, dir)
    } catch (error) {
      process.stdout.write(`\x1b[31m${(error as Error).message}\x1b[0m\n`)
    }
  }
  const schedule = () => {
    clearTimeout(timer)
    timer = setTimeout(draw, 120)
  }
  draw()
  watch(dir, (_event, name) => {
    if (name === 'diagram.mmd' || name === 'options.json') schedule()
  })
  process.on('SIGWINCH', schedule)
}

function main() {
  const [command, ...rest] = process.argv.slice(2)
  const known = ['render', 'watch', 'close', 'themes']
  const { positional, flags } = parseArgs(known.includes(command) ? rest : process.argv.slice(2))
  if (flags.help) {
    console.log(USAGE)
    return
  }
  const theme = (flags.theme as string) ?? DEFAULT_THEME

  switch (known.includes(command) ? command : 'show') {
    case 'themes':
      console.log(Object.keys(THEMES).join('\n'))
      return
    case 'watch':
      return watchPane(resolve(positional[0] ?? fail('watch needs a directory')))
    case 'close': {
      if (!process.env.REX_SESSION) fail('close only works inside Rex')
      const pane = livePane(stateDir())
      if (pane) rex(['block', 'close', '-s', process.env.REX_SESSION, pane])
      console.log(pane ? 'Closed the Diagram pane.' : 'No Diagram pane is open.')
      return
    }
    case 'render': {
      const source = readSource(positional[0])
      const format = (flags.format as string) ?? 'text'
      const out = flags.o as string | undefined
      if (format === 'png') {
        if (!out) fail('png needs -o OUT')
        return renderPng(source, theme, resolve(out))
      }
      if (format !== 'text' && format !== 'svg') fail(`unknown format "${format}"`)
      const result =
        format === 'svg' ? renderSvg(source, theme) : renderText(source, theme, out ? 'none' : 'truecolor')
      if (out) writeFileSync(out, result)
      else process.stdout.write(`${result}\n`)
      return
    }
    default:
      return show(readSource(positional[0]), {
        mode: flags.image ? 'image' : 'text',
        theme,
        title: flags.title as string | undefined,
      })
  }
}

main()
