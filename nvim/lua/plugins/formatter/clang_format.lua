return {
	clang_format = {
		prepend_args = {
			"--style=file", -- use .clang-format file
			"--fallback-style=LLVM", -- FALLBACK if no .clang-format found
		},
		condition = function(self, ctx)
			-- Only format if .clang-format exists in project root
			return vim.fs.find({
				".clang-format",
				"_clang-format",
			}, { path = ctx.filename, upward = true })[1] ~= nil
		end,
	},
}
