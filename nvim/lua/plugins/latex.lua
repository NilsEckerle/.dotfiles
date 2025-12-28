return {
	"lervag/vimtex",
	ft = { "tex", "latex" },
	config = function()
		-- Basic VimTeX configuration
		vim.g.vimtex_view_method = "zathura"
		vim.g.vimtex_compiler_method = "latexmk"
		vim.g.vimtex_view_automatic = 1

		-- Set up compiler options with build directory
		vim.g.vimtex_compiler_latexmk = {
			aux_dir = "build",
			out_dir = "build", -- change to build
			callback = 1,
			continuous = 1,
			executable = "latexmk",
			options = {
				"-pdf",
				"-bibtex", -- Aktiviert bibtex/biber
				"-verbose",
				"-file-line-error",
				"-synctex=1",
				"-interaction=nonstopmode",
				"-shell-escape",
			},
		}

		-- Setup cursor movement timer to trigger VimtexView
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "tex", "latex" },
			callback = function()
				-- Create a timer for delayed execution
				local view_timer = vim.loop.new_timer()
				local timer_running = false

				-- Ensure we clean up the timer when buffer is unloaded
				vim.api.nvim_create_autocmd("BufUnload", {
					buffer = 0,
					callback = function()
						if view_timer then
							view_timer:stop()
							view_timer:close()
						end
					end,
				})

				-- Keymappings
				vim.api.nvim_buf_set_keymap(
					0,
					"n",
					"<Leader>ll",
					":VimtexCompile<CR>",
					{ noremap = true, silent = true }
				)
				vim.api.nvim_buf_set_keymap(0, "n", "<Leader>lv", ":VimtexView<CR>", { noremap = true, silent = true })
				vim.api.nvim_buf_set_keymap(0, "n", "<Leader>lc", ":VimtexClean<CR>", { noremap = true, silent = true })
				vim.api.nvim_buf_set_keymap(
					0,
					"n",
					"<Leader>le",
					":!tex4ebook %<CR>",
					{ noremap = true, silent = true }
				)
			end,
		})
	end,
}
