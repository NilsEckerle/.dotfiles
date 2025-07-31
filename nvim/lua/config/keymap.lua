---@diagnostic disable: missing-fields
local map = vim.keymap.set
map("i", "jj", "<esc>")
map("i", "kk", "<esc>")
map("n", "<esc>", "<cmd>noh<CR>", { noremap = true, silent = true })

-- LSP
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Declaration" })
map("n", "K", vim.lsp.buf.hover, { desc = "Show Informations" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Code Diagnostics" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })

map("n", "<leader>Gg", "<cmd>term lazygit<cr>", { desc = "lazygit" })

-- Replace without loosing p register
map("x", "<leader>p", '"_dP', { desc = "replace while keeping p register" })
map("n", "<leader>p", "p", { desc = "replace while keeping p register" })

-- Disable arrow keys
map("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
map("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
map("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
map("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

map("n", "<leader>o", function()
  local file_dir = vim.fn.expand("%:p:h")
  vim.fn.jobstart({"nemo", file_dir}, {
    detach = true,
    on_exit = function(_, code)
      if code ~= 0 then
        vim.notify("Failed to open Nemo", vim.log.levels.ERROR)
      end
    end
  })
end, { desc = "Open current file directory in Nemo" })
