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
		},
		config = function()
			-- Helper function to get git root
			local function get_git_root()
				local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
				if vim.v.shell_error ~= 0 then
					git_root = nil -- If not in a Git repo, fallback to default behavior
				end
				return git_root
			end

			local telescope_builtin = require("telescope.builtin")
			local function find_files_in_git_root()
				local git_root = get_git_root()
				if git_root == nil then
					git_root = nil -- If not in a Git repo, fallback to default behavior
				end
				telescope_builtin.find_files({
					cwd = git_root,
				})
			end

			vim.keymap.set("n", "<leader><leader>", find_files_in_git_root, { desc = "Find in Project Root" })
			vim.keymap.set("n", "<leader>ff", telescope_builtin.find_files, { desc = "Find Files" })
			vim.keymap.set("n", "<leader>fg", telescope_builtin.live_grep, { desc = "Find Grep" })
		end,
	},
}
