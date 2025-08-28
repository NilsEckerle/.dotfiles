-- lua/plugins/lsp/pyright.lua
return function(capabilities)
	require("lspconfig").pyright.setup({
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = true
		end,
		settings = {
			python = {
				analysis = {
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "workspace",
				},
			},
		},
	})
end
