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
			out_dir = ".",
			callback = 1,
			continuous = 1,
			executable = "latexmk",
			options = {
				"-pdf",
				"-verbose",
				"-file-line-error",
				"-synctex=1",
				"-interaction=nonstopmode",
			},
		}

		-- Setup cursor movement timer to trigger VimtexView
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "tex", "latex" },
			callback = function()
				-- Create a timer for delayed execution
				local view_timer = vim.loop.new_timer()
				local timer_running = false

				-- Set up autocmd for cursor movement
				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = 0,
					callback = function()
						-- Cancel previous timer if it exists
						if timer_running then
							view_timer:stop()
						end

						-- Set a new timer (500ms delay - adjust as needed)
						timer_running = true
						view_timer:start(
							500,
							0,
							vim.schedule_wrap(function()
								-- Only execute VimtexView if the document has been compiled
								if vim.fn.filereadable(vim.fn.expand("%:r") .. ".pdf") == 1 then
									vim.cmd("VimtexView")
								end
								timer_running = false
							end)
						)
					end,
				})

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
				vim.api.nvim_buf_set_keymap(0, "n", "<Leader>le", ":!tex4ebook %<CR>", {noremap = true, silent = true})
			end,
		})
	end,
}
