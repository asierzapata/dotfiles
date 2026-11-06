-- Port of the XY-Zed theme used in Zed (extensions/installed/xy-zed/themes/xy-zed.json).
-- Zed's translucent colours are blended onto the editor background.
vim.cmd("hi clear")
vim.o.background = "dark"
vim.g.colors_name = "xy-zed"

local bg, bg2, bg3 = "#121212", "#1b1b1b", "#0a0a0a"
local fg, muted, faint = "#f7f7f8", "#aca8ae", "#6b6b73"
local accent = "#7de486"
local red, yellow, green, cyan, blue = "#f82871", "#fee56c", "#96df71", "#08e7c5", "#10a793"

local function blend(color, alpha, base)
	base = base or bg
	local function ch(hex, i)
		return tonumber(hex:sub(i, i + 1), 16)
	end
	local out = "#"
	for _, i in ipairs({ 2, 4, 6 }) do
		out = out .. string.format("%02x", math.floor(ch(color, i) * alpha + ch(base, i) * (1 - alpha) + 0.5))
	end
	return out
end

local hl = {
	Normal = { fg = fg, bg = bg },
	NormalFloat = { fg = fg, bg = bg2 },
	FloatBorder = { fg = blend("#ffffff", 0.125), bg = bg2 },
	WinSeparator = { fg = blend("#ffffff", 0.125) },
	CursorLine = { bg = blend(accent, 0.063) },
	CursorLineNr = { fg = accent },
	LineNr = { fg = "#3b3b3b" },
	SignColumn = { bg = bg },
	Visual = { bg = blend(accent, 0.24) },
	Search = { bg = blend("#975c32", 0.31) },
	IncSearch = { fg = bg, bg = accent },
	CurSearch = { fg = bg, bg = accent },
	MatchParen = { bg = blend(accent, 0.31), bold = true },
	Pmenu = { fg = fg, bg = bg2 },
	PmenuSel = { bg = blend(accent, 0.31, bg2) },
	PmenuThumb = { bg = blend(muted, 0.19, bg2) },
	StatusLine = { fg = muted, bg = bg3 },
	StatusLineNC = { fg = faint, bg = bg3 },
	TabLine = { fg = muted, bg = bg2 },
	TabLineSel = { fg = fg, bg = bg },
	TabLineFill = { bg = bg2 },
	Title = { fg = "#85b8ff", bold = true },
	NonText = { fg = blend(fg, 0.063) },
	Whitespace = { fg = blend(fg, 0.063) },
	Directory = { fg = "#9cdcfe" },
	Folded = { fg = muted, bg = bg2 },
	ErrorMsg = { fg = red },
	WarningMsg = { fg = yellow },
	ModeMsg = { fg = accent },
	DiffAdd = { bg = "#184618" },
	DiffDelete = { bg = "#54051b" },
	DiffChange = { bg = "#5c5014" },
	DiffText = { bg = "#796b26" },
	Added = { fg = green },
	Removed = { fg = red },
	Changed = { fg = yellow },

	Comment = { fg = "#6a9955" },
	Constant = { fg = "#ff5858", bold = true },
	String = { fg = "#cd9069" },
	Character = { fg = "#cd9069" },
	Number = { fg = "#b4cda8" },
	Boolean = { fg = "#22c942", italic = true },
	Identifier = { fg = "#4cc2fb", bold = true },
	Function = { fg = "#dcdcaa" },
	Statement = { fg = "#c678dd" },
	Keyword = { fg = "#c678dd" },
	Operator = { fg = "#ffff00" },
	PreProc = { fg = "#c678dd" },
	Include = { fg = "#c678dd" },
	Type = { fg = cyan },
	Special = { fg = "#4788cc" },
	Delimiter = { fg = "#dcdcaa" },
	Tag = { fg = "#7ce184" },
	Underlined = { fg = "#85b8ff", underline = true },
	Todo = { fg = bg, bg = yellow, bold = true },

	["@variable"] = { fg = "#4cc2fb", bold = true },
	["@variable.member"] = { fg = "#9cdcfe" },
	["@property"] = { fg = "#9cdcfe" },
	["@constructor"] = { fg = "#ff5858" },
	["@attribute"] = { fg = "#4788cc", italic = true },
	["@tag"] = { fg = "#7ce184" },
	["@tag.attribute"] = { fg = "#9cdcfe" },
	["@tag.delimiter"] = { fg = "#dcdcaa" },
	["@punctuation.bracket"] = { fg = "#dcdcaa" },
	["@punctuation.delimiter"] = { fg = "#dcdcaa" },
	["@punctuation.special"] = { fg = "#4788cc" },
	["@string.escape"] = { fg = "#4788cc" },
	["@string.regexp"] = { fg = "#ff5858" },
	["@string.special.symbol"] = { fg = "#7ce184" },
	["@markup.heading"] = { fg = "#85b8ff", bold = true },
	["@markup.raw"] = { fg = "#ff5858" },
	["@markup.link"] = { fg = "#85b8ff", italic = true },
	["@markup.link.url"] = { fg = "#2f81f7" },
	["@markup.list"] = { fg = "#85b8ff" },
	["@markup.italic"] = { italic = true },
	["@markup.strong"] = { bold = true },
	["@lsp.type.property"] = { link = "@property" },
	["@lsp.type.parameter"] = { link = "@variable" },

	LspReferenceText = { bg = blend(accent, 0.15) },
	LspReferenceRead = { bg = blend(accent, 0.15) },
	LspReferenceWrite = { bg = blend(accent, 0.44) },
	LspInlayHint = { fg = blend(cyan, 0.5), italic = true },

	DiagnosticError = { fg = red },
	DiagnosticWarn = { fg = yellow },
	DiagnosticInfo = { fg = blue },
	DiagnosticHint = { fg = "#618399" },
	DiagnosticOk = { fg = green },
	DiagnosticVirtualTextError = { fg = red, bg = blend("#54051b", 0.6) },
	DiagnosticVirtualTextWarn = { fg = yellow, bg = blend("#5c5014", 0.6) },
	DiagnosticVirtualTextInfo = { fg = blue, bg = "#12231f" },
	DiagnosticVirtualTextHint = { fg = "#618399", bg = "#12231f" },
	DiagnosticUnderlineError = { undercurl = true, sp = red },
	DiagnosticUnderlineWarn = { undercurl = true, sp = yellow },
	DiagnosticUnderlineInfo = { undercurl = true, sp = blue },
	DiagnosticUnderlineHint = { undercurl = true, sp = "#618399" },

	GitSignsAdd = { fg = green },
	GitSignsChange = { fg = yellow },
	GitSignsDelete = { fg = red },
	GitSignsCurrentLineBlame = { fg = faint, italic = true },

	-- Copilot ghost text uses Zed's "predictive" colour.
	CopilotSuggestion = { fg = "#525252", italic = true },
	ComplHint = { fg = "#525252", italic = true },
}

for group, spec in pairs(hl) do
	vim.api.nvim_set_hl(0, group, spec)
end

local term = {
	"#1e2025", red, green, yellow, blue, "#c74cec", cyan, fg,
	"#40434c", "#8e0f3a", "#457c38", "#958334", "#1a5148", "#682681", "#008169", fg,
}
for i, color in ipairs(term) do
	vim.g["terminal_color_" .. (i - 1)] = color
end
