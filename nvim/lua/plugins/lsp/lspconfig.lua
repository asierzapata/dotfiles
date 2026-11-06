return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()

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

		local capabilities = require("blink.cmp").get_lsp_capabilities()

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

		-- oxlint runs from each project's node_modules, so Mason does not install or enable it.
		-- The default root is the nearest .oxlintrc.json, which can be a nested config without
		-- node_modules (Edpuzzle-Web's src/frontend/web). Prefer the folder that has the binary.
		local default_oxlint_root = vim.lsp.config.oxlint.root_dir
		vim.lsp.config("oxlint", {
			root_dir = function(bufnr, on_dir)
				for dir in vim.fs.parents(vim.api.nvim_buf_get_name(bufnr)) do
					local has_config = vim.uv.fs_stat(dir .. "/.oxlintrc.json") or vim.uv.fs_stat(dir .. "/.oxlintrc.jsonc")
					if has_config and vim.fn.executable(dir .. "/node_modules/.bin/oxlint") == 1 then
						return on_dir(dir)
					end
				end
				default_oxlint_root(bufnr, on_dir)
			end,
		})
		vim.lsp.enable("oxlint")

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
