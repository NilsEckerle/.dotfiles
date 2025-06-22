return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = { "nvim-lua/plenary.nvim" },

	opts = {
		workspaces = {
			{
				name = "zettelkasten",
				path = "~/Documents/Zettelkasten/",
			},
		},

		-- Disable UI features to suppress warning
		ui = {
			enable = false,
		},

		-- Enable completion
		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},

		-- Generate filenames with timestamp + title
		note_id_func = function(title)
			local timestamp = os.date("%Y%m%d%H%M")
			-- local clean_title = title:gsub(" ", "-"):lower()
			-- return timestamp .. "_" .. clean_title
			return timestamp
		end,

		-- Disable automatic frontmatter updates
		disable_frontmatter = true,

		-- OR use note_frontmatter_func to preserve existing frontmatter
		note_frontmatter_func = function(note)
			-- Don't modify existing frontmatter at all
			return {}
		end,

		templates = {
			folder = "Templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
		},

		-- Default to Permanent folder for new notes
		note_path_func = function(spec)
			return spec.dir / "Permanent" / (spec.id .. ".md")
		end,
	},

	config = function(_, opts)
		require("obsidian").setup(opts)

		-- Force conceallevel after obsidian setup
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				vim.opt_local.conceallevel = 0
			end,
		})

		local vault_dir = vim.fn.expand("~/Documents/Zettelkasten")

		-- Word limit toggle variable
		local word_limit_enabled = true

		local function is_in_vault()
			local buf_path = vim.fn.expand("%:p")
			return vim.startswith(buf_path, vault_dir)
		end
		
		-- Word limit functionality
    local function get_word_count()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local text = table.concat(lines, " ")
      local count = 0
      for word in text:gmatch("%S+") do
        count = count + 1
      end
      return count
    end

    local function should_enforce_limit()
      if not word_limit_enabled then return false end -- Check if word limit is enabled
      if not is_in_vault() then return false end
      
      local filename = vim.fn.expand("%:t")
      -- Skip templates and example files
      if filename:match("[Tt]emplate") or filename:match("[Ee]xample") then
        return false
      end
      
      return true
    end

    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = vault_dir .. "/*",
      callback = function()
        if is_in_vault() then
          local map = vim.keymap.set
          local opts_map = { noremap = true, silent = true }

          -- Word limit autocmd for this buffer
          vim.api.nvim_create_autocmd("InsertCharPre", {
            buffer = 0,
            callback = function()
              if should_enforce_limit() and get_word_count() >= 100 then
                vim.v.char = ""
                vim.notify("100 word limit reached in obsidian note!", vim.log.levels.WARN)
              end
            end,
          })

          -- Optional: Show word count on text changes
          vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
            buffer = 0,
            callback = function()
              if should_enforce_limit() then
                local count = get_word_count()
                vim.b.obsidian_word_count = string.format("Words: %d/100", count)
              end
            end,
          })

					-- Core Obsidian commands
					map("n", "<leader><leader>", "<cmd>ObsidianSearch<CR>", opts_map)
					map("n", "<leader>os", "<cmd>ObsidianQuickSwitch<CR>", opts_map)
					map("n", "<leader>ot", "<cmd>ObsidianTags<CR>", opts_map)
					map("n", "<leader>on", "<cmd>ObsidianNewNote<CR>", opts_map)
					map("n", "<leader>oL", "<cmd>ObsidianLinkNew<CR>", opts_map)
					map("n", "<leader>ol", "<cmd>ObsidianLink<CR>", opts_map)
					map("v", "<leader>ol", "<cmd>ObsidianLink<CR>", opts_map)
					map("n", "<leader>oo", "<cmd>ObsidianOpen<CR>", opts_map)
					map("n", "gf", "<cmd>ObsidianFollowLink<CR>", opts_map)
					map("n", "gd", "<cmd>ObsidianFollowLink<CR>", opts_map)
				end
			end,
		})

		-- Custom commands
		vim.api.nvim_create_user_command("ObsidianNewNote", function()
			vim.ui.input({ prompt = "Note title: " }, function(title)
				if title then
					local timestamp = os.date("%Y%m%d%H%M")
					-- local clean_title = title:gsub(" ", "-"):lower()
					-- local filename = timestamp .. "_" .. clean_title .. ".md"
					local filename = timestamp .. ".md"
					local filepath = vim.fn.expand("~/Documents/Zettelkasten/Permanent/" .. filename)

					-- Create file with exact template content
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
					vim.cmd("edit " .. filepath)
				end
			end)
		end, {})

		vim.api.nvim_create_user_command("ObsidianLinkNew", function()
			vim.ui.input({ prompt = "Note title: " }, function(title)
				if title then
					local timestamp = os.date("%Y%m%d%H%M")
					-- local clean_title = title:gsub " ", "-"):lower()
					-- local filename = timestamp .. "_" .. clean_title .. ".md"
					local filename = timestamp .. ".md"
					local filepath = vim.fn.expand("~/Documents/Zettelkasten/Permanent/" .. filename)

					-- Create file with exact template content
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

					-- Insert link at cursor position
					local link = "[[" .. timestamp .. "|" .. title .. "]]"
					vim.api.nvim_put({ link }, "c", true, true)
				end
			end)
		end, {})

		-- Toggle word limit command
		vim.api.nvim_create_user_command("ObsidianToggleWordLimit", function()
			word_limit_enabled = not word_limit_enabled
			local status = word_limit_enabled and "enabled" or "disabled"
			vim.notify("Word limit " .. status, vim.log.levels.INFO)
		end, {})
	end,
}
