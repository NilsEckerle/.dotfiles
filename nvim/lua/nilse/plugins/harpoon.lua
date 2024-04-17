return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("harpoon"):setup()
	end,

	vim.keymap.set("n", "<leader>ha", function()
		require("harpoon"):list():add()
	end, { desc = "[H]arpoon [A]dd file" }),

	vim.keymap.set("n", "<leader>hh", function()
		require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
	end, { desc = "[H]arpoon list" }),

	vim.keymap.set("n", "<leader>1", function()
		require("harpoon"):list():select(1)
	end, { desc = "Harpoon jump to [1]" }),

	vim.keymap.set("n", "<leader>2", function()
		require("harpoon"):list():select(2)
	end, { desc = "Harpoon jump to [2]" }),

	vim.keymap.set("n", "<leader>3", function()
		require("harpoon"):list():select(3)
	end, { desc = "Harpoon jump to [3]" }),

	vim.keymap.set("n", "<leader>4", function()
		require("harpoon"):list():select(4)
	end, { desc = "Harpoon jump to [4]" }),
}
