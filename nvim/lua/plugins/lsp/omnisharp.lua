-- lua/plugins/lsp/omnisharp.lua
return function(capabilities)
	-- C# LSP setup using OmniSharp with Mason bin path
	local omnisharp_path = vim.fn.stdpath("data") .. "/mason/bin/OmniSharp"
	
	if vim.fn.executable(omnisharp_path) == 1 then
		vim.lsp.config.omnisharp = {
			capabilities = capabilities,
			cmd = { 
				omnisharp_path,
				"--languageserver", 
				"--hostPID", tostring(vim.fn.getpid()) 
			},
			filetypes = { "cs", "vb" },
			root_markers = {
				"*.sln",
				"*.csproj",
				"global.json",
				"omnisharp.json",
				"function.json"
			},
			init_options = {},
			on_attach = function(client, bufnr)
				if client.server_capabilities.semanticTokensProvider then
					vim.lsp.semantic_tokens.start(bufnr, client.id)
				end
				if client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
				print("OmniSharp attached to buffer " .. bufnr)
			end,
			settings = {
				FormattingOptions = {
					EnableEditorConfigSupport = true,
					OrganizeImports = true,
				},
				Sdk = {
					IncludePrereleases = true,
				},
			},
		}
		vim.lsp.enable("omnisharp")
	else
		vim.notify("OmniSharp not found at: " .. omnisharp_path, vim.log.levels.WARN)
	end
end
