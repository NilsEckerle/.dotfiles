---@diagnostic disable: missing-fields
vim.keymap.set("i", "jj", "<esc>")
vim.keymap.set("i", "kk", "<esc>")
vim.keymap.set("n", "<esc>", "<cmd>noh<CR>", { noremap = true, silent = true })

local function get_git_root()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 then
		git_root = nil -- If not in a Git repo, fallback to default behavior
	end
	return git_root
end

local telescope_builtin = require("telescope.builtin")
local function find_files_in_git_root()
	local git_root = get_git_root()
	if git_root == nil then
		git_root = nil -- If not in a Git repo, fallback to default behavior
	end
	telescope_builtin.find_files({
		cwd = git_root,
	})
end

local function open_neotree_in_git_root()
	local git_root = get_git_root()
	if git_root == nil then
		git_root = "." -- If not in a Git repo, fallback to default behavior
	end
	vim.cmd("Neotree toggle dir=" .. git_root)
end

vim.keymap.set("n", "<leader><leader>", find_files_in_git_root, { desc = "Find in Project Root" })
vim.keymap.set("n", "<leader>ff", telescope_builtin.find_files, { desc = "Find in cwd" })

vim.keymap.set("n", "<leader>qq", "<cmd>x<cr>", { desc = "x" })
vim.keymap.set("n", "<leader>qQ", "<cmd>q!<cr>", { desc = "q!" })
vim.keymap.set("n", "<leader>qw", "<cmd>wq<cr>", { desc = "qw" })

-- vim.keymap.set("n", "<leader>e", open_neotree_in_git_root, { desc = "Open Neotree" } )
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open Oil" })

-- LSP
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Declaration" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show Informations" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
-- vim.keymap.set("n", "<leader>cd", vim.lsp.util.show_line_diagnostics, { desc = "Code Diagnostics" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>cf", function()
	require("conform").format()
end, { desc = "Format File" })

vim.keymap.set("n", "<leader>w", "<C-w>", { desc = "CTRL-w" })

vim.keymap.set("n", "<leader>gg", "<cmd>term lazygit<cr>", { desc = "lazygit" })

--- Replace without loosing p register
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "replace while keeping p register" })
vim.keymap.set("n", "<leader>p", "p", { desc = "replace while keeping p register" })
