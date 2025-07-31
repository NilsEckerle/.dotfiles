return {
	{
		"stevearc/oil.nvim",
		---@module "oil"
		---@type oil.SetupOpts
		opts = {},
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		config = function(opts)
			require("oil").setup(opts)

			vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Oil up baby" })

			-- Set buffer-local keymap for Oil buffers
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "oil",
				callback = function()
					vim.keymap.set("n", "<leader>o", function()
						local oil = require("oil")
						local dir = oil.get_current_dir()
						if dir then
							vim.fn.jobstart({ "nemo", dir }, { detach = true })
						else
							-- Fallback to current working directory
							vim.fn.jobstart({ "nemo", vim.fn.getcwd() }, { detach = true })
						end
					end, { desc = "Open directory in Nemo", buffer = true })
				end,
			})
		end,
	},
}
