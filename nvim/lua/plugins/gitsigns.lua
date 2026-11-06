return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		-- Zed shows the last commit for the cursor line inline.
		current_line_blame = true,
		current_line_blame_opts = { delay = 600, ignore_whitespace = true },
		current_line_blame_formatter = "<author>, <author_time:%R> • <summary>",
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns

			local function map(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
			end

			-- ]c/[c move between hunks like Zed, and keep their built-in meaning inside diff mode.
			local function nav(key, direction)
				return function()
					if vim.wo.diff then
						vim.cmd.normal({ key, bang = true })
					else
						gs.nav_hunk(direction)
					end
				end
			end
			map("n", "]c", nav("]c", "next"), "Next hunk")
			map("n", "[c", nav("[c", "prev"), "Prev hunk")
			map("n", "]h", function()
				gs.nav_hunk("next")
			end, "Next hunk")
			map("n", "[h", function()
				gs.nav_hunk("prev")
			end, "Prev hunk")

			map("n", "<leader>hs", gs.stage_hunk, "Stage/unstage hunk")
			map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
			map("v", "<leader>hs", function()
				gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Stage/unstage hunk")
			map("v", "<leader>hr", function()
				gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Reset hunk")
			map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
			map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
			map("n", "<leader>hp", gs.preview_hunk_inline, "Preview hunk inline")
			map("n", "<leader>hb", function()
				gs.blame_line({ full = true })
			end, "Blame line")
			map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle inline blame")
			map("n", "<leader>hd", gs.diffthis, "Diff this")
			map("n", "<leader>hD", function()
				gs.diffthis("~")
			end, "Diff this ~")

			map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
		end,
	},
}
