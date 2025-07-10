vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = false
vim.opt.list = true
vim.opt.listchars = {
	tab = '▸ ',
	trail = '-',
-- 	space = '·',
-- 	eol = '¬',
-- 	extends = '❯',
-- 	precedes = '❮',
-- 	nbsp = '⦸'
}

vim.opt.colorcolumn = "80"
vim.opt.guicursor = "n-v-i-c:block"
vim.opt.scrolloff = 10
vim.opt.conceallevel = 1
vim.opt.breakindent = true

vim.opt.foldenable = true
vim.opt.foldlevelstart = 99 -- Opens all folds when entering a buffer
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- fold via treesitter context (functions, classes, ...)
vim.opt.foldcolumn = "0" -- disables fold column
vim.opt.foldtext = "" -- shows the code line in folded state

vim.opt.mouse = ""

vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "no"

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight wen yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Make visual selection darker
vim.cmd('highlight Visual guibg=#101010 ctermbg=237')

-- disable popup when changing config
require("lazy").setup({
	change_detection = {
		enabled = false,
		notify = false,
	},
})
