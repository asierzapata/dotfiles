-- Zed's vim mode treats f, c and a as function, class and argument text objects.
return {
	"echasnovski/mini.ai",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		-- Only its queries are used; mini.ai does the selecting.
		{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
	},
	opts = function()
		local ts = require("mini.ai").gen_spec.treesitter
		return {
			n_lines = 500,
			custom_textobjects = {
				f = ts({ a = "@function.outer", i = "@function.inner" }),
				c = ts({ a = "@class.outer", i = "@class.inner" }),
			},
		}
	end,
}
