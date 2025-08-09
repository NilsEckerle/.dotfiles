return {
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local luasnip = require("luasnip")
      luasnip.setup({ enable_autosnippets = true })
      require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })

      -- keymaps
      local map = vim.keymap.set
      map("i", "<C-h>", function() luasnip.expand() end, { silent = true })
      map("i", "<C-J>", function() luasnip.jump(1) end, { silent = true })
      map("i", "<C-K>", function() luasnip.jump(-1) end, { silent = true })
    end
  },
}
