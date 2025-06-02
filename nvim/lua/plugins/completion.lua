return {
	{
		"hrsh7th/nvim-cmp",
		event = "VeryLazy",
		dependencies = {
			-- Snippet engine
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
			
			-- Completion sources
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			
			-- More explicit snippet loading
			local friendly_path = vim.fn.stdpath("data") .. "/lazy/friendly-snippets"
			require("luasnip.loaders.from_vscode").lazy_load({ 
					paths = { friendly_path },
					include = nil,  -- Load all languages
					exclude = {}
			})
			
			-- Also try the standard load
			require("luasnip.loaders.from_vscode").load({
					paths = { friendly_path .. "/snippets" }
			})
			
			luasnip.filetype_extend("tex", { "all" })
    
			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				-- Configure completion behavior
				completion = {
					completeopt = "menu,menuone,noinsert",  -- Show menu, select first item, but don't insert
				},

				-- Configure preselect behavior
				preselect = cmp.PreselectMode.Item,  -- Preselect first item
				
				-- Your preferred keybindings
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					
					-- Tab for snippet navigation
					["<Tab>"] = cmp.mapping(function(fallback)
						if luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				
				sources = cmp.config.sources({
					{ name = "luasnip" },
					{ name = "nvim_lsp" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
				}),
				
				formatting = {
					format = function(entry, vim_item)
						-- Show source name
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
				
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
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
					{ name = "path" }
				}, {
					{ name = "cmdline" }
				})
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
					{ name = "buffer" }
				}
			})
		end,
	},
}

	-- {
	--	"saghen/blink.cmp",
	--	dependencies = {
	--		"L3MON4D3/LuaSnip",
	--		"rafamadriz/friendly-snippets",
	--	},
	--	version = "*",
	--	---@module 'blink.cmp'
	--	---@type blink.cmp.Config
	--	opts = {
	--		keymap = { preset = "default" },
	--		appearance = {
	--			use_nvim_cmp_as_default = false,
	--			nerd_font_variant = "mono",
	--		},
	--		sources = {
	--			-- Reorder to prioritize path over snippets
	--			default = { "lsp", "path", "buffer", "snippets" },
	--			providers = {
	--				path = {
	--					name = "Path",
	--					module = "blink.cmp.sources.path",
	--					score_offset = 10, -- Higher priority
	--					opts = {
	--						trailing_slash = false,
	--						label_trailing_slash = true,
	--						get_cwd = function(context)
	--							return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
	--						end,
	--						show_hidden_files_by_default = false,
	--					}
	--				},
	--				snippets = {
	--					score_offset = -5, -- Lower priority
	--				}
	--			}
	--		},
	--		completion = {
	--			accept = {
	--				auto_brackets = {
	--					enabled = false,
	--				},
	--			},
	--			documentation = {
	--				auto_show = true,
	--				auto_show_delay_ms = 0,
	--			},
	--		},
	--		snippets = {
	--			expand = function(snippet)
	--				require("luasnip").lsp_expand(snippet)
	--			end,
	--			active = function(filter)
	--				if filter and filter.direction then
	--					return require("luasnip").jumpable(filter.direction)
	--				end
	--				return require("luasnip").in_snippet()
	--			end,
	--			jump = function(direction)
	--				require("luasnip").jump(direction)
	--			end,
	--		},
	--	},
	--	opts_extend = { "sources.default" },
	-- },
