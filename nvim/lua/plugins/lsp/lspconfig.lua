return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		-- Navigation keys (gd, gD, gy, gI, gA, gr, gs, gS) live in snacks.lua so they use its pickers.
		-- These mirror Zed's vim-mode defaults for the remaining LSP actions.
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local function map(mode, lhs, rhs, desc)
					keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
				end

				map("n", "K", vim.lsp.buf.hover, "Hover")
				map("n", "gh", vim.lsp.buf.hover, "Hover")
				map({ "n", "x" }, "g.", vim.lsp.buf.code_action, "Code actions")
				map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code actions")
				map("n", "cd", vim.lsp.buf.rename, "Rename symbol")
				map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
				map("n", "<leader>d", vim.diagnostic.open_float, "Line diagnostics")
				map("n", "<leader>D", function()
					Snacks.picker.diagnostics_buffer()
				end, "Buffer diagnostics")
				map("n", "[d", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end, "Previous diagnostic")
				map("n", "]d", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end, "Next diagnostic")
				map("n", "<leader>rs", "<cmd>LspRestart<CR>", "Restart LSP")
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Neovim 0.11+ hides inline diagnostics by default; Zed shows them.
		vim.diagnostic.config({
			virtual_text = { spacing = 2, prefix = "●" },
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
		})

		-- mason-lspconfig enables every installed server; these only override the defaults
		-- that nvim-lspconfig ships for each one.
		vim.lsp.config("*", { capabilities = capabilities })

		vim.lsp.config("svelte", {
			on_attach = function(client)
				vim.api.nvim_create_autocmd("BufWritePost", {
					pattern = { "*.js", "*.ts" },
					callback = function(ctx)
						client:notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
					end,
				})
			end,
		})

		vim.lsp.config("graphql", {
			filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		})

		vim.lsp.config("emmet_ls", {
			filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
		})

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					completion = { callSnippet = "Replace" },
				},
			},
		})
	end,
}
