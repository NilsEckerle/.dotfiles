return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			preset = "helix", -- classic, modern, helix
			delay = 10000,
			spec = {
				{ "<leader>", group = "Leader key for most keybindings" },
				{ "z", group = "[z]old" },
			},
		},
		keys = {
			{
				"<leader>G?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
			{
				"<leader>?",
				function()
					require("which-key").show({ global = true })
				end,
				desc = "Global Keymaps (which-key)",
			},
		},
	},
}
