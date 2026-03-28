return function(capabilities)
	vim.lsp.config["r_language_server"] = {
		capabilities = capabilities,
		filetypes = { "r", "rmd" },
	}
	vim.lsp.enable("r_language_server")
end
