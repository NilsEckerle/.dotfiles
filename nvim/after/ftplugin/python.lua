local set = vim.opt_local

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.py",
    callback = function()
        vim.keymap.set("n", "<leader>R", function()
            local file = vim.fn.expand("%:p")
            local term_buf = vim.api.nvim_create_buf(false, true)
            local width = math.floor(vim.o.columns * 0.8)
            local height = math.floor(vim.o.lines * 0.8)
            local row = math.floor((vim.o.lines - height) / 2)
            local col = math.floor((vim.o.columns - width) / 2)

            vim.api.nvim_open_win(term_buf, true, {
                relative = "editor",
                row = row,
                col = col,
                width = width,
                height = height,
                style = "minimal",
                border = "rounded",
            })

            vim.fn.termopen("python3 " .. vim.fn.shellescape(file))
            vim.cmd("startinsert")
        end, { desc = "Run Python File in Floating Terminal" })
    end,
})


