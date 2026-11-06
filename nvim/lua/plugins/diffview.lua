return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
	keys = {
		{ "<leader>gv", "<cmd>DiffviewOpen<CR>", desc = "Diff view (working tree)" },
		{ "<leader>gV", "<cmd>DiffviewClose<CR>", desc = "Close diff view" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Branch history" },
	},
	opts = {},
}
