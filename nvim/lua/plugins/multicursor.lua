-- Zed vim-mode multi-cursor keys: gl/gL add the next/previous match, g>/g< skip it,
-- ga selects every match, and <Esc> clears the extra cursors.
return {
	"jake-stewart/multicursor.nvim",
	branch = "1.0",
	event = "VeryLazy",
	config = function()
		local mc = require("multicursor-nvim")
		mc.setup()

		local set = vim.keymap.set
		set({ "n", "x" }, "gl", function()
			mc.matchAddCursor(1)
		end, { desc = "Add cursor at next match" })
		set({ "n", "x" }, "gL", function()
			mc.matchAddCursor(-1)
		end, { desc = "Add cursor at previous match" })
		set({ "n", "x" }, "g>", function()
			mc.matchSkipCursor(1)
		end, { desc = "Skip to next match" })
		set({ "n", "x" }, "g<", function()
			mc.matchSkipCursor(-1)
		end, { desc = "Skip to previous match" })
		set({ "n", "x" }, "ga", mc.matchAllAddCursors, { desc = "Add cursors at all matches" })
		set("n", "<c-leftmouse>", mc.handleMouse)
		set("n", "<c-leftdrag>", mc.handleMouseDrag)
		set("n", "<c-leftrelease>", mc.handleMouseRelease)

		mc.addKeymapLayer(function(layerSet)
			layerSet("n", "<esc>", mc.clearCursors)
		end)

		vim.api.nvim_set_hl(0, "MultiCursorCursor", { reverse = true })
		vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
	end,
}
