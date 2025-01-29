vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.colorcolumn = "80"
vim.opt.guicursor = "n-v-i-c:block"
vim.opt.scrolloff = 10

vim.opt.foldenable = true
vim.opt.foldlevelstart = 99 -- Opens all folds when entering a buffer
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- fold via treesitter context (functions, classes, ...)
vim.opt.foldcolumn = "0" -- disables fold column
vim.opt.foldtext = "" -- shows the code line in folded state

vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "no"

vim.opt.ignorecase = true

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight wen yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- disable popup when changing config
require("lazy").setup({
	change_detection = {
		enabled = false,
		notify = false,
	},
})
