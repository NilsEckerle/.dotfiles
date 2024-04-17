vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.clipboard = "unnamedplus"

vim.opt.confirm = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.g.have_nerd_font = true

vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"

-- vim.opt.splitright = true
-- vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = "|->", trail = "*", nbsp = "␣" }
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
-- vim.opt.expandtab = true
vim.opt.expandtab = false

vim.opt.cursorline = true
vim.opt.colorcolumn = "80"

vim.opt.scrolloff = 10

vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
