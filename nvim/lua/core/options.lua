vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indentation from current line when starting new one

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if I include mixed cased, assumes case-sensitive search mode

opt.cursorline = true -- adds a highlight to the current cursor line

opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text does not shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line and insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical windwos to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- Save on focus change, like Zed's "autosave": "on_focus_change".
opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "WinLeave" }, {
	group = vim.api.nvim_create_augroup("AutosaveOnFocusChange", { clear = true }),
	callback = function(ev)
		local bo = vim.bo[ev.buf]
		if bo.modified and bo.buftype == "" and bo.modifiable and not bo.readonly and vim.api.nvim_buf_get_name(ev.buf) ~= "" then
			vim.api.nvim_buf_call(ev.buf, function()
				vim.cmd("silent! update")
			end)
		end
	end,
})
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	group = vim.api.nvim_create_augroup("ReloadOnFocus", { clear = true }),
	command = "silent! checktime",
})
