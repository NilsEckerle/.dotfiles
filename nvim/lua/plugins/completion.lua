return {
	{
		"hrsh7th/nvim-cmp",
		event = "VeryLazy",
		dependencies = {
			-- Completion sources
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-calc",
			"hrsh7th/cmp-calc",

			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"olimorris/codecompanion.nvim",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			-- Register nvim-cmp lsp capabilities
			vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })

			-- Load snippets from friendly-snippets (optional)
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				-- Configure snippet engine
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				-- Configure completion behavior
				completion = {
					completeopt = "menu,menuone,noinsert", -- Show menu, select first item, but don't insert
				},
				-- Configure preselect behavior
				preselect = cmp.PreselectMode.Item, -- Preselect first item
				-- Your preferred keybindings
				mapping = cmp.mapping.preset.insert({
					["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
					["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-h>"] = cmp.mapping.confirm({ select = true }),
					-- ["<C-Space>"] = cmp.mapping.complete(),
					-- ["<C-e>"] = cmp.mapping.abort(),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
				}),

				sources = cmp.config.sources({
					{ name = "codecompanion" },
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "luasnip" },
					{ name = "calc" },
					{ name = "nvim_lsp_signature_help" },
				}, {
					{ name = "buffer" },
				}),

				formatting = {
					format = function(entry, vim_item)
						-- Show source name
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							buffer = "[Buffer]",
							path = "[Path]",
							luasnip = "[Snip]",
						})[entry.source.name]
						return vim_item
					end,
				},

				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),

					-- completion = {
					-- 	-- border = "rounded", -- or 'single', 'double', 'shadow', etc.
					-- 	-- winhighlight = "Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None",
					-- 	maxheight = 20,
					-- 	maxwidth = 60,
					-- },
					-- documentation = {
					-- 	-- border = "rounded", -- or 'single', 'double', 'shadow', etc.
					-- 	-- winhighlight = "Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None",
					-- 	maxheight = 20,
					-- 	maxwidth = 80,
					-- },
				},

				-- Enable experimental ghost text (optional)
				experimental = {
					ghost_text = false,
				},
			})

			-- Command line completion with same behavior
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline({
					["<C-j>"] = { c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }) },
					["<C-k>"] = { c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }) },
					["<C-y>"] = { c = cmp.mapping.confirm({ select = true }) },
				}),
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})

			-- Search completion with same behavior
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline({
					["<C-j>"] = { c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }) },
					["<C-k>"] = { c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }) },
					["<C-y>"] = { c = cmp.mapping.confirm({ select = true }) },
				}),
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				sources = {
					{ name = "buffer" },
				},
			})
		end,
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "InsertEnter",
		opts = {
			bind = true,
			handler_opts = {
				border = "none",
			},
			hint_enable = false,
		},
	},
}
