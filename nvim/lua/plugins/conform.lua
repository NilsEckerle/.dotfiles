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
				},
				formatters = {
					clang_format = {
						prepend_args = {
							"--style=file", -- use .clang-format file
							"--fallback-style=LLVM", -- FALLBACK if no .clang-format found
						},
            condition = function(self, ctx)
              -- Only format if .clang-format exists in project root
              return vim.fs.find({
                ".clang-format",
                "_clang-format",
              }, { path = ctx.filename, upward = true })[1] ~= nil
            end,
					},
				},
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
