local opt = vim.opt

local v = vim.version()
if v.major > 0 or v.minor >= 12 then
	require("vim._core.ui2").enable({
		enable = true,
		msg = {
			target = "cmd",
			pager = { height = 0.5 },
			dialog = { height = 0.5 },
			cmd = { height = 0.5 },
			msg = { height = 0.5, timeout = 4500 },
		},
	})
end

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

opt.number = true
opt.relativenumber = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.list = true
opt.listchars = {
	tab = "▸ ",
	trail = "-",
	-- 	space = '·',
	-- 	eol = '¬',
	extends = "❯",
	precedes = "❮",
	-- 	nbsp = '⦸'
}

opt.colorcolumn = "100"
opt.guicursor = "n-v-i-c:block"
opt.scrolloff = 10
opt.conceallevel = 1
opt.breakindent = true

-- opt.textwidth = 80
-- opt.formatoptions = "tcrjna"

opt.foldenable = true
opt.foldlevelstart = 99 -- Opens all folds when entering a buffer
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- fold via treesitter context (functions, classes, ...)
opt.foldcolumn = "0" -- disables fold column
opt.foldtext = "" -- shows the code line in folded state

-- opt.mouse = ""

opt.clipboard = "unnamedplus"
-- opt.signcolumn = "no"
vim.opt.signcolumn = "auto:1" -- Show only when needed, 1 column wide

opt.ignorecase = true
opt.smartcase = true

opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight wen yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

function vim.get_visual_selection()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg("v")
	vim.fn.setreg("v", {})

	text = string.gsub(text, "\n", "")
	if #text > 0 then
		return text
	else
		return ""
	end
end

-- Set .h files to be recognized as C instead of C++
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*.h",
	callback = function()
		vim.bo.filetype = "c"
	end,
})

-- Set .tcss files to be recognized as css
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.tcss",
	callback = function()
		vim.bo.filetype = "css"
	end,
})
