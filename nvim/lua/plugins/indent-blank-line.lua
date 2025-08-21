return {
    "lukas-reineke/indent-blankline.nvim",
    ft = { "python", "lua" },
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {
        indent = {
            char = "│",
            tab_char = "│",
        },
        scope = {
            enabled = true,
            show_start = false,
            show_end = true,
            show_exact_scope = true,
        },
    },
}
