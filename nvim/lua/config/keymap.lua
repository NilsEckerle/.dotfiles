---@diagnostic disable: missing-fields
local map = vim.keymap.set
map("i", "jj", "<esc>")
map("i", "kk", "<esc>")
map("n", "<esc>", "<cmd>noh<CR>", { noremap = true, silent = true })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode with double ESC" })

-- LSP
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Declaration" })
map("n", "K", vim.lsp.buf.hover, { desc = "Show Informations" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Code Diagnostics" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })

map("n", "<down>", "<cmd>cnext<CR>", { desc = "Quickfix next" })
map("n", "<up>", "<cmd>cprev<CR>", { desc = "Quickfix previous" })
map("n", "<left>", "<cmd>cclose<CR>", { desc = "Quickfix close" })
map("n", "<right>", "<cmd>copen<CR>", { desc = "Quickfix open" })

map("n", "<leader>Gg", "<cmd>term lazygit<cr>", { desc = "lazygit" })

-- Replace without loosing p register
map("x", "<leader>p", '"_dP', { desc = "replace while keeping p register" })
map("n", "<leader>p", "p", { desc = "replace while keeping p register" })

map("n", "<leader>o", function()
	local file_dir = vim.fn.expand("%:p:h")
	vim.fn.jobstart({ "nemo", file_dir }, {
		detach = true,
		on_exit = function(_, code)
			if code ~= 0 then
				vim.notify("Failed to open Nemo", vim.log.levels.ERROR)
			end
		end,
	})
end, { desc = "Open current file directory in Nemo" })

map("n", "<leader>ai", "<CMD>CodeCompanionChat<CR>")
map("v", "<leader>ai", "<CMD>CodeCompanion<CR>")
