vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>qq", "<cmd>:q<CR>", { desc = "quit" })
vim.keymap.set("n", "<leader>qw", "<cmd>:wq<CR>", { desc = "write quit" })
vim.keymap.set("n", "<leader>qf", "<cmd>:q!<CR>", { desc = "force quit" })
-- vim.keymap.set({ "n", "v" }, "H", "_", { desc = "jump to end of line" })
-- vim.keymap.set({ "n", "v" }, "L", "$", { desc = "jump to begin of line" })
