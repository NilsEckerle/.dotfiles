-- lua/plugins/lsp/clangd.lua
return function(capabilities)
	vim.lsp.config.clangd = {
		cmd = { "clangd" },
		filetypes = { "c", "cpp", "objc", "objcpp" },
		root_markers = {
			".clangd",
			".clang-tidy",
			".clang-format",
			"compile_commands.json",
			"compile_flags.txt",
			"build"
		},
		capabilities = capabilities,
		on_attach = function(client, bufnr)
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
