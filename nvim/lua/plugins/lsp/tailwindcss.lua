-- lua/plugins/lsp/tailwindcss.lua
return function(capabilities)
	vim.lsp.config.tailwindcss = {
		filetypes = {
			"html",
			"css",
			"scss",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
			"tcss",
		},
	}
	vim.lsp.enable("tailwindcss")
end
