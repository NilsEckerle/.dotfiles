vim.api.nvim_create_autocmd("FileType", {
	pattern = "codecompanion",
	callback = function()
		if vim.b.cc_auto_pinned then
			return
		end
		vim.b.cc_auto_pinned = true
		vim.defer_fn(function()
			local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			local me_idx = nil
			for i, line in ipairs(lines) do
				if line:match("^## Me$") then
					me_idx = i - 1
					break
				end
			end
			if not me_idx then
				me_idx = #lines
			end
			vim.api.nvim_buf_set_lines(0, me_idx + 2, me_idx + 2, false, { "#{buffer}" })
		end, 50)
	end,
})

return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			strategies = {
				chat = {
					adapter = "ollama",
					model = "qwen2.5-coder:7b",
				},
				inline = {
					adapter = "ollama",
					model = "qwen2.5-coder:7b",
				},
				agent = {
					adapter = "ollama",
					model = "qwen2.5-coder:7b",
				},
			},
		},
	},
}
