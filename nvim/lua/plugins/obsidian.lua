return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },

  opts = {
    workspaces = {
      {
        name = "zettelkasten",
        path = "~/Documents/Zettelkasten/", -- Updated to match your actual path
      },
    },

    -- Generate filenames with timestamp + title (consistent with your templates)
    note_id_func = function(title)
      local timestamp = os.date("%Y%m%d%H%M")
      local clean_title = title:gsub(" ", "-"):lower()
      return timestamp .. "_" .. clean_title
    end,

    note_frontmatter_func = function(note)
      -- Return nil to prevent automatic frontmatter generation
      -- We'll let the templates handle all frontmatter
      return nil
    end,

    -- Template support
    templates = {
      folder = "Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },

    -- Note path function to place notes in appropriate folders
    note_path_func = function(spec)
      -- Default to Fleeting folder if no specific folder is determined
      local folder = "Fleeting"
      
      -- You can add logic here to determine folder based on tags or other criteria
      if spec.tags and vim.tbl_contains(spec.tags, "literatur") then
        folder = "Literatur"
      elseif spec.tags and vim.tbl_contains(spec.tags, "permanent") then
        folder = "Permanent"
      end
      
      return spec.dir / folder / (spec.id .. ".md")
    end,
  },

  config = function(_, opts)
    require("obsidian").setup(opts)

    local vault_dir = vim.fn.expand("~/Documents/Zettelkasten")

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
          local opts_map = { noremap = true, silent = true }

          -- Core Obsidian commands
          map("n", "<leader><leader>", "<cmd>ObsidianSearch<CR>", opts_map)
          map("n", "<leader>os", "<cmd>ObsidianQuickSwitch<CR>", opts_map)
          map("n", "<leader>ot", "<cmd>ObsidianTags<CR>", opts_map)
          map("n", "<leader>on", "<cmd>ObsidianNew<CR>", opts_map)
          map("n", "<leader>oi", "<cmd>ObsidianLink<CR>", opts_map)
          map("n", "<leader>oI", "<cmd>ObsidianLinkNew<CR>", opts_map)
          map("n", "<leader>oo", "<cmd>ObsidianOpen<CR>", opts_map)
          map("n", "gf", "<cmd>ObsidianFollowLink<CR>", opts_map)
          
          -- Template commands with title prompt
          map("n", "<leader>tf", function()
            vim.ui.input({ prompt = "Note title: " }, function(title)
              if title then
                -- Create empty note first
                local timestamp = os.date("%Y%m%d%H%M")
                local clean_title = title:gsub(" ", "-"):lower()
                local filename = timestamp .. "_" .. clean_title .. ".md"
                local filepath = vim.fn.expand("~/Documents/Zettelkasten/Fleeting/" .. filename)
                
                -- Create the file and open it
                vim.fn.writefile({}, filepath)
                vim.cmd("edit " .. filepath)
                
                -- Apply template
                vim.defer_fn(function()
                  vim.cmd("ObsidianTemplate fleeting-nvim")
                end, 50)
              end
            end)
          end, opts_map)
          
          map("n", "<leader>tl", function()
            vim.ui.input({ prompt = "Note title: " }, function(title)
              if title then
                local timestamp = os.date("%Y%m%d%H%M")
                local clean_title = title:gsub(" ", "-"):lower()
                local filename = timestamp .. "_" .. clean_title .. ".md"
                local filepath = vim.fn.expand("~/Documents/Zettelkasten/Literatur/" .. filename)
                
                vim.fn.writefile({}, filepath)
                vim.cmd("edit " .. filepath)
                
                vim.defer_fn(function()
                  vim.cmd("ObsidianTemplate literatur-nvim")
                end, 50)
              end
            end)
          end, opts_map)
          
          map("n", "<leader>tp", function()
            vim.ui.input({ prompt = "Note title: " }, function(title)
              if title then
                local timestamp = os.date("%Y%m%d%H%M")
                local clean_title = title:gsub(" ", "-"):lower()
                local filename = timestamp .. "_" .. clean_title .. ".md"
                local filepath = vim.fn.expand("~/Documents/Zettelkasten/Permanent/" .. filename)
                
                vim.fn.writefile({}, filepath)
                vim.cmd("edit " .. filepath)
                
                vim.defer_fn(function()
                  vim.cmd("ObsidianTemplate permanent-nvim")
                end, 50)
              end
            end)
          end, opts_map)
        end
      end,
    })

    -- Custom commands for creating notes with templates and title prompt
    vim.api.nvim_create_user_command("ObsidianFleeting", function()
      vim.ui.input({ prompt = "Note title: " }, function(title)
        if title then
          local timestamp = os.date("%Y%m%d%H%M")
          local clean_title = title:gsub(" ", "-"):lower()
          local filename = timestamp .. "_" .. clean_title .. ".md"
          local filepath = vim.fn.expand("~/Documents/Zettelkasten/Fleeting/" .. filename)
          
          vim.fn.writefile({}, filepath)
          vim.cmd("edit " .. filepath)
          
          vim.defer_fn(function()
            vim.cmd("ObsidianTemplate fleeting-nvim")
          end, 50)
        end
      end)
    end, {})

    vim.api.nvim_create_user_command("ObsidianLiteratur", function()
      vim.ui.input({ prompt = "Note title: " }, function(title)
        if title then
          local timestamp = os.date("%Y%m%d%H%M")
          local clean_title = title:gsub(" ", "-"):lower()
          local filename = timestamp .. "_" .. clean_title .. ".md"
          local filepath = vim.fn.expand("~/Documents/Zettelkasten/Literatur/" .. filename)
          
          vim.fn.writefile({}, filepath)
          vim.cmd("edit " .. filepath)
          
          vim.defer_fn(function()
            vim.cmd("ObsidianTemplate literatur-nvim")
          end, 50)
        end
      end)
    end, {})

    vim.api.nvim_create_user_command("ObsidianPermanent", function()
      vim.ui.input({ prompt = "Note title: " }, function(title)
        if title then
          local timestamp = os.date("%Y%m%d%H%M")
          local clean_title = title:gsub(" ", "-"):lower()
          local filename = timestamp .. "_" .. clean_title .. ".md"
          local filepath = vim.fn.expand("~/Documents/Zettelkasten/Permanent/" .. filename)
          
          vim.fn.writefile({}, filepath)
          vim.cmd("edit " .. filepath)
          
          vim.defer_fn(function()
            vim.cmd("ObsidianTemplate permanent-nvim")
          end, 50)
        end
      end)
    end, {})
  end,
}
