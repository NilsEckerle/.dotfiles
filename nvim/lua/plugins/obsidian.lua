return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },

  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/Documents/mealprep",
      },
    },

    note_id_func = function(title)
      return title -- Just use the title as the filename
    end,

    note_frontmatter_func = function(note)
      return {
        title = note.title,
        aliases = {},
        tags = {},
      }
    end,
  },

  config = function(_, opts)
    require("obsidian").setup(opts) -- Ensure Obsidian.nvim gets the opts

    local vault_dir = vim.fn.expand("~/Documents/mealprep")

    -- Function to check if the current file is inside the vault
    local function is_in_vault()
      local buf_path = vim.fn.expand("%:p")
      return vim.startswith(buf_path, vault_dir)
    end

    -- Keybindings for when inside the vault
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = vault_dir .. "/*",
      callback = function()
        if is_in_vault() then
          local map = vim.keymap.set
          local opts = { noremap = true, silent = true }

          map("n", "<leader><leader>", "<cmd>ObsidianSearch<CR>", opts)
          map("n", "<leader>os", "<cmd>ObsidianQuickSwitch<CR>", opts)
          map("n", "<leader>ot", "<cmd>ObsidianTags<CR>", opts)
          map("n", "<leader>on", "<cmd>ObsidianNew<CR>", opts)
          map("n", "<leader>oi", "<cmd>ObsidianLink<CR>", opts)
          map("n", "<leader>oI", "<cmd>ObsidianLinkNew<CR>", opts)
          map("n", "<leader>oo", "<cmd>ObsidianOpen<CR>", opts)
          map("n", "gf", "<cmd>ObsidianFollowLink<CR>", opts)
        end
      end,
    })
  end,
}
