return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = (build_cmd ~= "cmake") and "make"
        or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        enabled = build_cmd ~= nil,
        config = function(plugin)
          LazyVim.on_load("telescope.nvim", function()
            local ok, err = pcall(require("telescope").load_extension, "fzf")
            if not ok then
              local lib = plugin.dir .. "/build/libfzf." .. (LazyVim.is_win() and "dll" or "so")
              if not vim.uv.fs_stat(lib) then
                LazyVim.warn("`telescope-fzf-native.nvim` not built. Rebuilding...")
                require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
                  LazyVim.info("Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim.")
                end)
              else
                LazyVim.error("Failed to load `telescope-fzf-native.nvim`:\n" .. err)
              end
            end
          end)
        end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enabled = true },
    },
    config = function()
      local opts = {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({
              -- even more opts
            }),
          },
        },
        defaults = {
          layout_config = {
            horizontal = {
              width = 0.90,
              height = 0.80,
              preview_width = 0.4, -- Increased for better preview
            },
          },
          -- Path display configuration
          path_display = { "truncate" }, -- Options: "hidden", "tail", "absolute", "smart", "shorten", "truncate"

          -- Better formatting for file paths
          file_ignore_patterns = {
            "%.git/",
            "node_modules/",
            "%.cache/",
          },
        },

        -- Specific configuration for LSP pickers
        pickers = {
          lsp_references = {
            -- Show full file paths
            path_display = { "smart" }, -- Shows shortened paths intelligently

            -- Layout specific to lsp_references
            layout_config = {
              horizontal = {
                width = 0.95,
                height = 0.85,
                preview_width = 0.50,
              },
            },

            -- Show more context
            show_line = false,
            trim_text = false,

            -- Include file type icons
            include_current_line = true,
          },

          -- Similar config for other LSP pickers
          lsp_definitions = {
            path_display = { "smart" },
            show_line = true,
          },

          lsp_implementations = {
            path_display = { "smart" },
            show_line = true,
          },

          lsp_type_definitions = {
            path_display = { "smart" },
            show_line = true,
          },
        },
      }
      local telescope = require("telescope")
			telescope.setup(opts)
			local telescope_builtin = require("telescope.builtin")
			
			-- Load extensions
			telescope.load_extension("ui-select")
			
			-- Helper function to get git root
			local function get_git_root()
				local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
				if vim.v.shell_error ~= 0 then
					git_root = nil
				end
				return git_root
			end
			
			local function find_files_in_git_root()
				local git_root = get_git_root()
				telescope_builtin.find_files({
					cwd = git_root,
				})
			end
			
			local function telescope_grep_selection()
				local selection = vim.get_visual_selection()
				telescope_builtin.live_grep({ default_text = selection })
			end
			
			local map = vim.keymap.set
			map("n", "<leader><leader>", find_files_in_git_root, { desc = "Find in Project Root" })
			map("n", "<leader>ff", telescope_builtin.find_files, { desc = "Find Files" })
			map("n", "<leader>g", telescope_builtin.live_grep, { desc = "Find Grep" })
			map("v", "<leader>g", telescope_grep_selection, { desc = "Search selected text in files" })
      map("n", "<leader>cR", require('telescope.builtin').lsp_references, { desc = "Telescope references", })
		end,
	},
}
