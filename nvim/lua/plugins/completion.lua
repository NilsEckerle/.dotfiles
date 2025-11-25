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

			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

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
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					-- ["<C-Space>"] = cmp.mapping.complete(),
					-- ["<C-e>"] = cmp.mapping.abort(),
					-- ["<C-d>"] = cmp.mapping.scroll_docs(4),
					-- ["<C-u>"] = cmp.mapping.scroll_docs(-4),
				}),

				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "luasnip" },
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
					-- completion = cmp.config.window.bordered(),
					-- documentation = cmp.config.window.bordered(),
				},
			})

			-- Command line completion with same behavior
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline({
					["<C-n>"] = { c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }) },
					["<C-p>"] = { c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }) },
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
					["<C-n>"] = { c = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }) },
					["<C-p>"] = { c = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }) },
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
}
