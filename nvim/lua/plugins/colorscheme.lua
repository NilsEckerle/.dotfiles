return {
  -- add gruvbox
  {
    "ellisonleao/gruvbox.nvim",
  },

  {
    "tribela/transparent.nvim",
    event = "VimEnter",
    config = true,
    auto = true,
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
