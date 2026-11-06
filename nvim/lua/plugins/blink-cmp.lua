return {
	"saghen/blink.cmp",
	version = "1.*",
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = { "rafamadriz/friendly-snippets" },
	opts = {
		keymap = {
			preset = "enter",
			["<C-j>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			-- <Tab> accepts the Copilot prediction first, as in Zed, then jumps through snippets.
			["<Tab>"] = {
				function()
					local ok, suggestion = pcall(require, "copilot.suggestion")
					if ok and suggestion.is_visible() then
						suggestion.accept()
						return true
					end
				end,
				"snippet_forward",
				"fallback",
			},
		},
		appearance = { nerd_font_variant = "mono" },
		completion = {
			list = { selection = { preselect = true, auto_insert = false } },
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
			menu = { border = "rounded", draw = { treesitter = { "lsp" } } },
			accept = { auto_brackets = { enabled = true } },
		},
		signature = { enabled = true, window = { border = "rounded" } },
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
}
