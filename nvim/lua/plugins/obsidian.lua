-- ============================================================================
-- CONFIGURATION VARIABLES
-- ============================================================================
local VAULT_PATH = "/home/nils/Documents/Zettelkasten/"
local VAULT_NAME = "Zettelkasten"

return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = { "nvim-lua/plenary.nvim" },

	-- ========================================================================
	-- PLUGIN OPTIONS
	-- ========================================================================
	opts = {
		workspaces = {
			{
				name = VAULT_NAME,
				path = VAULT_PATH,
			},
		},

		ui = { enable = false },
		disable_frontmatter = true,

		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},

		templates = {
			folder = "Templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
		},

		-- Generate timestamp-based note IDs
		note_id_func = function(title)
			return os.date("%Y%m%d%H%M")
		end,

		-- Save new notes to Permanent folder
		note_path_func = function(spec)
			return spec.dir / "Permanent" / (spec.id .. ".md")
		end,

		-- Don't modify existing frontmatter
		note_frontmatter_func = function(note)
			return {}
		end,
	},

	-- ========================================================================
	-- PLUGIN CONFIGURATION
	-- ========================================================================
	config = function(_, opts)
		require("obsidian").setup(opts)

		-- ====================================================================
		-- GLOBAL VARIABLES
		-- ====================================================================
		local vault_dir = VAULT_PATH:gsub("/$", "") -- Remove trailing slash
		local word_limit_enabled = true

		-- ====================================================================
		-- UTILITY FUNCTIONS
		-- ====================================================================
		local function is_in_vault()
			local buf_path = vim.fn.expand("%:p")
			return vim.startswith(buf_path, vault_dir)
		end

		local function get_word_count()
			local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			local text = table.concat(lines, " ")
			local count = 0
			for word in text:gmatch("%S+") do
				count = count + 1
			end
			return count
		end

		local function should_enforce_word_limit()
			if not word_limit_enabled or not is_in_vault() then
				return false
			end

			local filename = vim.fn.expand("%:t")
			-- Skip templates and example files
			if filename:match("[Tt]emplate") or filename:match("[Ee]xample") then
				return false
			end

			return true
		end

		-- ====================================================================
		-- KEYMAP SETUP
		-- ====================================================================
		local function setup_keymaps()
			if not is_in_vault() then
				return
			end

			local map = vim.keymap.set
			local opts = { noremap = true, silent = true, buffer = 0 }

			-- Search and navigation
			map("n", "<leader><leader>", "<cmd>ObsidianSearch<CR>", opts)
			map("n", "<leader>os", "<cmd>ObsidianQuickSwitch<CR>", opts)
			map("n", "<leader>ot", "<cmd>ObsidianTags<CR>", opts)
			map("n", "gf", "<cmd>ObsidianFollowLink<CR>", opts)
			map("n", "gd", "<cmd>ObsidianFollowLink<CR>", opts)

			-- Note creation and linking
			map("n", "<leader>on", "<cmd>ObsidianNewNote<CR>", opts)
			map("n", "<leader>oL", "<cmd>ObsidianLinkNew<CR>", opts)
			map("n", "<leader>ol", "<cmd>ObsidianLink<CR>", opts)
			map("v", "<leader>ol", "<cmd>ObsidianLink<CR>", opts)

			-- Open in Obsidian app
			map("n", "<leader>oo", "<cmd>ObsidianOpen<CR>", opts)
		end

		-- ====================================================================
		-- WORD LIMIT FUNCTIONALITY
		-- ====================================================================
		local function setup_word_limit()
			-- Prevent typing when word limit is reached
			vim.api.nvim_create_autocmd("InsertCharPre", {
				buffer = 0,
				callback = function()
					if should_enforce_word_limit() and get_word_count() >= 100 then
						vim.v.char = ""
						vim.notify("100 word limit reached!", vim.log.levels.WARN)
					end
				end,
			})

			-- Show word count on text changes
			vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
				buffer = 0,
				callback = function()
					if should_enforce_word_limit() then
						local count = get_word_count()
						vim.b.obsidian_word_count = string.format("Words: %d/100", count)
					end
				end,
			})
		end

		-- Toggle word limit on/off
		local function toggle_word_limit()
			word_limit_enabled = not word_limit_enabled
			local status = word_limit_enabled and "enabled" or "disabled"
			vim.notify("Word limit " .. status, vim.log.levels.INFO)
		end

		-- ====================================================================
		-- AUTOCMDS
		-- ====================================================================
		-- Disable concealing in markdown files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				vim.opt_local.conceallevel = 0
			end,
		})

		-- Setup keymaps and word limit for vault files
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
			pattern = vault_dir .. "/*",
			callback = function()
				setup_keymaps()
				setup_word_limit()
			end,
		})

		-- Fallback keymap setup for all markdown files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				vim.defer_fn(setup_keymaps, 100)
			end,
		})

		-- ====================================================================
		-- NOTE CREATION FUNCTIONALITY
		-- ====================================================================
		local function create_note_template(title)
			local timestamp = os.date("%Y%m%d%H%M")
			local filename = timestamp .. ".md"
			local filepath = vault_dir .. "/Permanent/" .. filename

			local template_content = {
				"---",
				'id: "' .. timestamp .. '"',
				"aliases:",
				'  - "' .. title .. '"',
				"tags:",
				"  - inbox",
				"---",
				"# " .. title,
				"",
			}

			vim.fn.writefile(template_content, filepath)
			return timestamp, filepath
		end

		local function create_new_note()
			vim.ui.input({ prompt = "Note title: " }, function(title)
				if not title then
					return
				end

				local timestamp, filepath = create_note_template(title)
				vim.cmd("edit " .. filepath)
			end)
		end

		local function create_and_link_note()
			vim.ui.input({ prompt = "Note title: " }, function(title)
				if not title then
					return
				end

				local timestamp, filepath = create_note_template(title)

				-- Insert link at cursor
				local link = "[[" .. timestamp .. "|" .. title .. "]]"
				vim.api.nvim_put({ link }, "c", true, true)
			end)
		end
		-- ====================================================================
		-- CUSTOM COMMANDS
		-- ====================================================================
		vim.api.nvim_create_user_command("ObsidianNewNote", create_new_note, {})
		vim.api.nvim_create_user_command("ObsidianLinkNew", create_and_link_note, {})
		vim.api.nvim_create_user_command("ObsidianToggleWordLimit", toggle_word_limit, {})
	end,
}
