return {
	{ 
		"ellisonleao/gruvbox.nvim", 
		priority = 1000, 
		config = function() 
			vim.cmd.colorscheme "default" 
			vim.opt.termguicolors = false
			vim.opt.number = true
			vim.opt.relativenumber = true
		end, 
		opt = ... 
	},
}
