return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		-- Zed runs `source.fixAll` code actions before the formatter on save. ESLint and oxlint
		-- both offer it; requesting it synchronously keeps the fixes ahead of prettier.
		local function fix_all(bufnr)
			for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
				if client.name == "eslint" or client.name == "oxlint" then
					local last_line = vim.api.nvim_buf_line_count(bufnr)
					local response = client:request_sync("textDocument/codeAction", {
						textDocument = vim.lsp.util.make_text_document_params(bufnr),
						range = { start = { line = 0, character = 0 }, ["end"] = { line = last_line, character = 0 } },
						context = { only = { "source.fixAll" }, diagnostics = {} },
					}, 1000, bufnr)
					for _, action in ipairs(response and response.result or {}) do
						if action.edit then
							vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
						end
					end
				end
			end
		end

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" },
			},
			format_on_save = function(bufnr)
				fix_all(bufnr)
				return { lsp_format = "fallback", timeout_ms = 1000 }
			end,
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
