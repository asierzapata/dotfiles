-- Follows the macOS appearance like Zed's "theme": { "mode": "system" }:
-- XY-Zed (nvim/colors/xy-zed.lua) when dark, One Light when light.
return {
	{
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("onedark").setup({ style = "light" })
			vim.cmd.colorscheme("xy-zed")
		end,
	},
	{
		"f-person/auto-dark-mode.nvim",
		lazy = false,
		priority = 999,
		opts = {
			update_interval = 3000,
			set_dark_mode = function()
				vim.cmd.colorscheme("xy-zed")
			end,
			set_light_mode = function()
				vim.o.background = "light"
				require("onedark").setup({ style = "light" })
				vim.cmd.colorscheme("onedark")
			end,
		},
	},
}
