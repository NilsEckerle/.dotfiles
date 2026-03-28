-- lua/plugins/lsp.lua
local mason_ensure_installed = {
	"stylua",
	"shfmt",
	"clangd",
	"codelldb",
	"gopls",
	"rust-analyzer",
	"pyright",
	-- "basedpyright",
	"omnisharp",
	"latexindent",
	"texlab",
	"cmakelang",
	"cmakelint",
	"r-languageserver",
}

return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"folke/lazydev.nvim",
				ft = "lua", -- only load on lua files
				opts = {
					library = {
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"j-hui/fidget.nvim",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Load individual language server configurations
			require("plugins.lsp.lua-ls")(capabilities)
			require("plugins.lsp.pyright")(capabilities)
			require("plugins.lsp.clangd")(capabilities)
			require("plugins.lsp.neocmake")(capabilities)
			require("plugins.lsp.omnisharp")(capabilities)
			require("plugins.lsp.texlab")(capabilities)
			require("plugins.lsp.r-languageserver")(capabilities)

			-- Global LSP keymaps
			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP actions",
				callback = function(event)
					local buffer = event.buf
					vim.keymap.set(
						"n",
						"K",
						"<cmd>lua vim.lsp.buf.hover()<cr>",
						{ buffer = buffer, desc = "Show hover information" }
					)
					vim.keymap.set(
						"n",
						"gd",
						"<cmd>lua vim.lsp.buf.definition()<cr>",
						{ buffer = buffer, desc = "Go to definition" }
					)
					vim.keymap.set(
						"n",
						"gD",
						"<cmd>lua vim.lsp.buf.declaration()<cr>",
						{ buffer = buffer, desc = "Go to declaration" }
					)
					vim.keymap.set(
						"n",
						"gi",
						"<cmd>lua vim.lsp.buf.implementation()<cr>",
						{ buffer = buffer, desc = "Go to implementation" }
					)
					vim.keymap.set(
						"n",
						"<leader>cr",
						vim.lsp.buf.references,
						{ buffer = buffer, desc = "LSP references" }
					)
				end,
			})
		end,
	},
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		build = ":MasonUpdate",
		opts_extend = { "ensure_installed" },
		opts = {
			ensure_installed = mason_ensure_installed,
		},
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			mr:on("package:install:success", function()
				vim.defer_fn(function()
					require("lazy.core.handler.event").trigger({
						event = "FileType",
						buf = vim.api.nvim_get_current_buf(),
					})
				end, 100)
			end)
			mr.refresh(function()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end)
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "omnisharp" },
				automatic_installation = true,
			})
		end,
	},
	{
		"chrisgrieser/nvim-lsp-endhints",
		event = "LspAttach",
		opts = {},
		config = function()
			require("lsp-endhints").setup({
				icons = {
					type = "󰊕 ",
					parameter = "󰘦 ",
					offspec = "󰞘 ",
					unknown = "󰘨 ",
				},
				label = {
					truncateAtChars = 20,
					padding = 1,
					marginLeft = 0,
					sameKindSeparator = ", ",
				},
				extmark = {
					priority = 50,
				},
				autoEnableHints = true,
			})
		end,
	},
}
