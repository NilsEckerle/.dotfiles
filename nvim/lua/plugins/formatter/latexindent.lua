return {
	latexindent = {
		prepend_args = {
			"-m", -- modify line breaks
			"-l", -- use local settings
			stdin = true,
			timeout_ms = 5000,
		},
		condition = function(self, ctx)
			-- Only format if .latexindent.yaml exists (optional)
			return vim.fs.find({
				".latexindent.yaml",
			}, { path = ctx.filename, upward = true })[1] ~= nil
		end,
	},
}
