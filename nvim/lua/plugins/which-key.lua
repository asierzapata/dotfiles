return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	opts = {
		-- leaving it empty uses the default settings
		spec = {
			{ "<leader>a", group = "ai" },
		},
	},
}
