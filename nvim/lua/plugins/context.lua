return {
	"nvim-treesitter/nvim-treesitter-context",
	config = function()
		require("treesitter-context").setup({
			enable = true,
			line_numbers = true,
			multiline_treshold = 10,
			mode = 'topline' -- 'cursor',
		})
	end,
}
