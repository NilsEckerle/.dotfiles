return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "isort", "black" },
					rust = { "rustfmt", lsp_format = "fallback" },
					javascript = { "prettierd", "prettier", stop_after_first = true },
					c = { "clang_format" },
					cpp = { "clang_format" },
					tex = { "latexindent" },
					plaintex = { "latexindent" },
				},
				formatters = vim.tbl_extend(
					"force",
					{},
					require("plugins.formatter.clang_format"),
					require("plugins.formatter.latexindent")
				),
				format_on_save = {
					timeout_ms = 500,
					lsp_format = true,
				},
			})

			local function format()
				require("conform").format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 500,
				})
			end

			vim.keymap.set({ "n", "v" }, "<leader>cf", format, { desc = "Format file or range (in visual mode)" })
		end,
	},
}
