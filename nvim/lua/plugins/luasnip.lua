return {
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
          require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
        end,
      },
      "evesdropper/luasnip-latex-snippets.nvim",
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
      enable_autosnippets = true,
    },
  },
}
-- return {
--   {
--     "L3MON4D3/LuaSnip",
--     lazy = true,
--     dependencies = {
--       "evesdropper/luasnip-latex-snippets.nvim",
--     },
--     config = function()
--       local luasnip = require("luasnip")
--       luasnip.setup({
--         enable_autosnippets = true,
--         delete_check_events = "TextChanged",
--       })
--       require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })
--
--       -- keymaps
--       local map = vim.keymap.set
--       map("i", "<C-h>", function() luasnip.expand() end, { silent = true })
--       map("i", "<C-J>", function() luasnip.jump(1) end, { silent = true })
--       map("i", "<C-K>", function() luasnip.jump(-1) end, { silent = true })
--     end
--   },
-- }
