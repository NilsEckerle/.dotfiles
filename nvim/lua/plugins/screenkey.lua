return {
    {
        "NStefan002/screenkey.nvim",
        cmd = "Screenkey",
        version = "*",
        config = function()
            require("screenkey").setup {}

            vim.api.nvim_create_user_command("ScreenkeyDisable", function()
                if require("screenkey").is_active() then
                    vim.cmd("Screenkey")
                end
            end, { desc = "Disable Screenkey plugin if it is enabled" })

            vim.api.nvim_create_autocmd({ "BufEnter" }, {
                pattern = { "*.env", ".env/*" },
                callback = function()
                    vim.cmd("ScreenkeyDisable")
                end,
            })
        end,
    },
}
