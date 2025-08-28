local set = vim.opt_local
local floating_term = require('floating-terminal')

local run_python_file = function()
    local file = vim.fn.expand("%:p")
    floating_term.run_command("python3 " .. vim.fn.shellescape(file))
end

local run_python_interactive = function()
    floating_term.run_command("python3")
end

local install_requirements = function()
    floating_term.run_command("pip install -r requirements.txt")
end

-- Python-specific keymaps
vim.keymap.set("n", "<leader>R", run_python_file, { desc = "Run Python File in Floating Terminal", buffer = true })
vim.keymap.set("n", "<leader>I", run_python_interactive, { desc = "Start Python REPL", buffer = true })
vim.keymap.set("n", "<leader>P", install_requirements, { desc = "Install Requirements", buffer = true })

-- Terminal toggle keymap
vim.keymap.set("n", "<leader>t", floating_term.toggle, { desc = "Toggle Floating Terminal" })
