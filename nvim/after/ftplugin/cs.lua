local floating_term = require('floating-terminal')

vim.opt.makeprg = "dotnet build src"

-- Set errorformat to parse .NET build output
vim.opt.errorformat = {
  "%f(%l\\,%c): %t%*[^:]: %m", -- .NET format: file(line,col): error/warning: message
  "%f(%l): %t%*[^:]: %m",       -- .NET format: file(line): error/warning: message  
  "%f: %t%*[^:]: %m",           -- .NET format: file: error/warning: message
  "%-G%.%#",                    -- Ignore other lines
}

local run_project = function()
  floating_term.run_command("dotnet run --no-build --project src")
end

local build_project = function()
  floating_term.run_command("dotnet build src")
end

-- Filetype-specific keymaps
vim.keymap.set("n", "<leader>R", run_project, { desc = "Run C# Project in Floating Terminal", buffer = true })
vim.keymap.set("n", "<leader>B", build_project, { desc = "Build C# Project in Floating Terminal", buffer = true })

-- Global keymaps (these will be set every time, but it's fine since they're the same)
vim.keymap.set("n", "<leader>make", "<cmd>make<CR>", { desc = "Build this C# project" })
vim.keymap.set("n", "<leader>run", run_project, { desc = "Run C# Project in Floating Terminal" })

-- Terminal toggle keymap (global)
vim.keymap.set("n", "<leader>t", floating_term.toggle, { desc = "Toggle Floating Terminal" })
