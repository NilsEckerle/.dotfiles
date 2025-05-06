local set = vim.opt_loca

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.c",
    callback = function()
				local cflags = "-g -Wall "

        vim.keymap.set("n", "<leader>cR", function()
            local file = vim.fn.expand("%:p")
            local term_buf = vim.api.nvim_create_buf(false, true)
            local width = math.floor(vim.o.columns * 0.8)
            local height = math.floor(vim.o.lines * 0.8)
            local row = math.floor((vim.o.lines - height) / 2)
            local col = math.floor((vim.o.columns - width) / 2)

            local win = vim.api.nvim_open_win(term_buf, true, {
                relative = "editor",
                row = row,
                col = col,
                width = width,
                height = height,
                style = "minimal",
                border = "rounded",
            })

						local cmd = "gcc -o main ".. cflags .. vim.fn.shellescape(file) .. " && chmod +x main" .. " && ./main"

            vim.cmd("terminal")
            vim.cmd("startinsert")
            vim.api.nvim_chan_send(vim.b.terminal_job_id, cmd .. "\n")
        end, { desc = "Compile and run only this file." })

        vim.keymap.set("n", "<leader>cC", function()
            local file = vim.fn.expand("%:p")
            local term_buf = vim.api.nvim_create_buf(false, true)
            local width = math.floor(vim.o.columns * 0.8)
            local height = math.floor(vim.o.lines * 0.8)
            local row = math.floor((vim.o.lines - height) / 2)
            local col = math.floor((vim.o.columns - width) / 2)

            local win = vim.api.nvim_open_win(term_buf, true, {
                relative = "editor",
                row = row,
                col = col,
                width = width,
                height = height,
                style = "minimal",
                border = "rounded",
            })

						local cmd = "gcc -o main " .. cflags .. vim.fn.shellescape(file)

            vim.cmd("terminal")
            vim.cmd("startinsert")
            vim.api.nvim_chan_send(vim.b.terminal_job_id, cmd .. "\n")
        end, { desc = "Compile only this file to main and make it executable."})

        vim.keymap.set("n", "<leader>cX", function()
            local file = vim.fn.expand("%:p")
            local term_buf = vim.api.nvim_create_buf(false, true)
            local width = math.floor(vim.o.columns * 0.8)
            local height = math.floor(vim.o.lines * 0.8)
            local row = math.floor((vim.o.lines - height) / 2)
            local col = math.floor((vim.o.columns - width) / 2)

            local win = vim.api.nvim_open_win(term_buf, true, {
                relative = "editor",
                row = row,
                col = col,
                width = width,
                height = height,
                style = "minimal",
                border = "rounded",
            })

						local cmd = "./main"

            vim.cmd("terminal")
            vim.cmd("startinsert")
            vim.api.nvim_chan_send(vim.b.terminal_job_id, cmd .. "\n")
        end, { desc = "Run already compiled main file"})
    end,
})


