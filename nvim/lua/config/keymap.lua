---@diagnostic disable: missing-fields
vim.keymap.set("i", "jj", "<esc>")
vim.keymap.set("i", "kk", "<esc>")
vim.keymap.set("n", "<esc>", "<cmd>noh<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open Oil" })

-- LSP
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Declaration" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show Informations" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Code Diagnostics" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })

vim.keymap.set("n", "<leader>gg", "<cmd>term lazygit<cr>", { desc = "lazygit" })

-- Replace without loosing p register
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "replace while keeping p register" })
vim.keymap.set("n", "<leader>p", "p", { desc = "replace while keeping p register" })

-- Disable arrow keys
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

vim.keymap.set("n", "<leader>o", function()
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
