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
			out_dir = "build",
			callback = 1,
			continuous = 1,
			executable = "latexmk",
			options = {
				"-pdf",
				"-bibtex",
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

				-- Auto-update Zathura view when cursor moves (only if viewer is running)
				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = 0,
					callback = function()
						-- Check if VimTeX viewer is running
						if vim.b.vimtex and vim.b.vimtex.viewer and vim.b.vimtex.viewer.xwin_id then
							-- Stop the timer if it's already running
							if timer_running then
								view_timer:stop()
							end

							-- Start a new timer (500ms delay to avoid too frequent updates)
							timer_running = true
							view_timer:start(
								3000,
								0,
								vim.schedule_wrap(function()
									timer_running = false
									-- Get current window address before calling VimtexView
									local current_window =
										vim.fn.system("hyprctl activewindow -j | jq -r '.address'"):gsub("%s+", "")
									vim.cmd("silent! VimtexView")
									-- Refocus nvim window after a short delay
									vim.defer_fn(function()
										vim.fn.system("hyprctl dispatch focuswindow address:" .. current_window)
									end, 50)
								end)
							)
						end
					end,
				})

				-- Setup which-key group for LaTeX
				local status_ok, which_key = pcall(require, "which-key")
				if status_ok then
					which_key.add({
						{ "<localleader>l", group = "LaTeX", buffer = 0 },
					})
				end
			end,
		})
	end,
}
