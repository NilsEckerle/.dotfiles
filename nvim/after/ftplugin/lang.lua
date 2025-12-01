-- Use C syntax highlighting
vim.bo.syntax = "c"

-- Stop any LSP clients that might attach
vim.defer_fn(function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	for _, client in ipairs(clients) do
		vim.lsp.stop_client(client.id)
	end
end, 100)
