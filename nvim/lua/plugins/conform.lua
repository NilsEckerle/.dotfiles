return {
    {
        'stevearc/conform.nvim',
		event = { "BufReadPre", "BufNewFile" },
        opts = {},
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    lua = { "stylua" },
                    python = { "isort", "black" },
                    rust = { "rustfmt", lsp_format = "fallback" },
                    javascript = { "prettierd", "prettier", stop_after_first = true },
                },
            })
			vim.keymap.set({"n", "v"}, "<leader>cf", function ()
				require("conform").format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 500,
				})
			end, {desc = "Format file or range (in visual mode)"})
        end,
    }
}
