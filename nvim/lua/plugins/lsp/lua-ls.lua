-- lua/plugins/lsp/lua-ls.lua
return function(capabilities)
	require("lspconfig").lua_ls.setup({
		capabilities = capabilities,
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
				telemetry = {
					enable = false,
				},
			},
		},
	})
end
