return {
	{ 
		"ellisonleao/gruvbox.nvim", 
		priority = 1000, 
		config = function() 
			vim.cmd.colorscheme "gruvbox" 
			-- Check if we're in tmux within TTY
			local function is_tty_tmux()
				return os.getenv("TERM") == "screen" or 
				(os.getenv("TMUX") and os.getenv("TERM") == "linux")
			end

			if os.getenv("TERM") == "linux" or is_tty_tmux() then
				vim.opt.termguicolors = false
				vim.opt.number = true
				vim.opt.relativenumber = false
				vim.cmd([[
				set t_Co=8
				" Force visible line numbers in tmux+TTY
				highlight LineNr ctermfg=3 ctermbg=NONE
				highlight CursorLineNr ctermfg=7 ctermbg=NONE cterm=bold
				]])
			end
		end, 
		opt = ... 
	},
}
