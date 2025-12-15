return function(capabilities)
	vim.lsp.config.texlab = {
		cmd = { "texlab" },
		filetypes = { "tex", "plaintex", "bib" },
		root_markers = {
			".latexmkrc",
			".git",
			"*.tex",
		},
		capabilities = capabilities,
		settings = {
			texlab = {
				build = {
					executable = "latexmk",
					args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
					onSave = false, -- Set to true if you want auto-build on save
					forwardSearchAfter = false,
				},
				auxDirectory = ".",
				forwardSearch = {
					executable = nil, -- Set your PDF viewer here if needed
					args = {},
				},
				chktex = {
					onOpenAndSave = true,
					onEdit = false,
				},
				diagnosticsDelay = 300,
				latexFormatter = "latexindent",
				latexindent = {
					modifyLineBreaks = false,
				},
			},
		},
	}
	vim.lsp.enable("texlab")
end
