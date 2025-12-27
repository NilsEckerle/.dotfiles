return function(capabilities)
	vim.lsp.config.clangd = {
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
			"--header-insertion=iwyu",
			"--completion-style=detailed",
			"--function-arg-placeholders",
			"--fallback-style=llvm",
		},
		filetypes = { "c", "cpp", "objc", "objcpp" },
		root_markers = {
			".clangd",
			".clang-tidy",
			".clang-format",
			"_clang-format",
			"compile_commands.json",
			"compile_flags.txt",
			"build",
		},
		init_options = {
			usePlaceholders = true,
			completeUnimported = true,
			clangdFileStatus = true,
		},
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			-- client.server_capabilities.signatureHelpProvider = false
			-- Enable inlay hints if supported
			if client.server_capabilities.inlayHintProvider then
				vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
			end
		end,
		settings = {
			clangd = {
				InlayHints = {
					Designators = true,
					Enabled = true,
					ParameterNames = true,
					DeducedTypes = true,
				},
				fallbackFlags = { "-std=c17" },
			},
		},
	}
	vim.lsp.enable("clangd")
end
