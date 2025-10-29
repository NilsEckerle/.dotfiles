local set = vim.opt_local
local floating_term = require('floating-terminal')

local cflags = "-g -Wall "

local compile_and_run = function()
    local file = vim.fn.expand("%:p")
    local cmd = "g++ -o main " .. cflags .. vim.fn.shellescape(file) .. " && chmod +x main && ./main"
    floating_term.run_command(cmd)
end

local compile_only = function()
    local file = vim.fn.expand("%:p")
    local cmd = "g++ -o main " .. cflags .. vim.fn.shellescape(file)
    floating_term.run_command(cmd)
end

local run_main = function()
    floating_term.run_command("./main")
end

-- C-specific keymaps
vim.keymap.set("n", "<leader>cR", compile_and_run, { desc = "Compile and run only this file", buffer = true })
vim.keymap.set("n", "<leader>cC", compile_only, { desc = "Compile only this file to main and make it executable", buffer = true })
vim.keymap.set("n", "<leader>cX", run_main, { desc = "Run already compiled main file", buffer = true })

vim.keymap.set("n", "<leader>make", "<cmd>:make build<cr>", { buffer = true })
vim.keymap.set("n", "<leader>clean", "<cmd>:make clean<cr>", { buffer = true })
vim.keymap.set("n", "<leader>run", function() floating_term.send_command("make run") end, { buffer = true })

-- Terminal toggle keymap
vim.keymap.set("n", "<leader>t", floating_term.toggle, { desc = "Toggle Floating Terminal" })
