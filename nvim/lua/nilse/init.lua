require("nilse.setup")
require("nilse.important_keybindings")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)
local lazy = require("lazy")
lazy.setup({

	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	{ "numToStr/Comment.nvim", opts = {} }, -- Highlights TODO:

	require("nilse.plugins.whichkey"),
	require("nilse.plugins.telescope"),
	require("nilse.plugins.lsp-config"),
	require("nilse.plugins.autoformat"),
	require("nilse.plugins.autopairs"),
	require("nilse.plugins.nvim-cmp"),
	require("nilse.plugins.colorsceme"),
	require("nilse.plugins.todo-comments"),
	require("nilse.plugins.mini"),
	require("nilse.plugins.lazygit"),
	require("nilse.plugins.nvim-tree"),
	require("nilse.plugins.harpoon"),
})
