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

			-- Useful for getting pretty icons, but requires a Nerd Font.
			{ "nvim-tree/nvim-web-devicons", enabled = true },
		},
		opts = {
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown({
						-- even more opts
					}),

					-- pseudo code / specification for writing custom displays, like the one
					-- for "codeactions"
					-- specific_opts = {
					--   [kind] = {
					--     make_indexed = function(items) -> indexed_items, width,
					--     make_displayer = function(widths) -> displayer
					--     make_display = function(displayer) -> function(e)
					--     make_ordinal = function(e) -> string
					--   },
					--   -- for example to disable the custom builtin "codeactions" display
					--      do the following
					--   codeactions = false,
					-- }
				},
			},
			-- To get ui-select loaded and working with telescope, you need to call
			-- load_extension, somewhere after setup function:
		},
		config = function()
			local telescope = require("telescope")

			local ui_select = telescope.load_extension("ui-select")
			local telescope_builtin = require("telescope.builtin")

			-- Helper function to get git root
			local function get_git_root()
				local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
				if vim.v.shell_error ~= 0 then
					git_root = nil -- If not in a Git repo, fallback to default behavior
				end
				return git_root
			end

			local function find_files_in_git_root()
				local git_root = get_git_root()
				if git_root == nil then
					git_root = nil -- If not in a Git repo, fallback to default behavior
				end
				telescope_builtin.find_files({
					cwd = git_root,
				})
			end

			local function telescope_grep_selection()
				local selection = vim.get_visual_selection()
				telescope_builtin.live_grep({ default_text = selection });
			end

			local map = vim.keymap.set
			map("n", "<leader><leader>", find_files_in_git_root, { desc = "Find in Project Root" })
			map("n", "<leader>ff", telescope_builtin.find_files, { desc = "Find Files" })
			map("n", "<leader>g", telescope_builtin.live_grep, { desc = "Find Grep" })
			map("v", "<leader>g", telescope_grep_selection, { desc = "Search selected text in files" })
		end,
	},
}
