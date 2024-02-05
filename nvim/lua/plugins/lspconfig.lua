return {
  {
    -- this automatically installs tailwindcss when not installed
    -- optionally you coud install it over masion
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {},
      },
    },
  },
}
