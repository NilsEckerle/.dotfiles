local set = vim.opt_local
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.tex",
	callback = function()
		local file = vim.fn.expand("%:p") -- Full file path
		local dir = vim.fn.expand("%:p:h") -- Get file's directory

		vim.fn.jobstart({ "pdflatex", "-output-directory", dir, file }, {
			stdout_buffered = true,
			stderr_buffered = true,
			on_stdout = function(_, _) end, -- Ignore stdout
			on_stderr = function(_, _) end, -- Ignore stderr
			detach = true, -- Run in background
		})
	end,
})
