return {
	{
		"L3MON4D3/LuaSnip",
		lazy = true,
		dependencies = {
			{
				"rafamadriz/friendly-snippets",
				config = function()
					require("luasnip.loaders.from_vscode").lazy_load()
					require("luasnip.loaders.from_vscode").lazy_load({
						paths = { vim.fn.stdpath("config") .. "/snippets" },
					})
				end,
			},
			"evesdropper/luasnip-latex-snippets.nvim",
		},
		opts = {
			history = true,
			delete_check_events = "TextChanged",
			enable_autosnippets = true,
		},
		config = function(_, opts)
			local luasnip = require("luasnip")
			luasnip.setup(opts)
			require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })

			-- keymaps
			local map = vim.keymap.set
			map("i", "<C-h>", function()
				luasnip.expand()
			end, { silent = true })
			map("i", "<C-j>", function()
				luasnip.jump(1)
			end, { silent = true })
			map("i", "<C-k>", function()
				luasnip.jump(-1)
			end, { silent = true })
		end,
	},
}
