return {
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        dependencies = {
            {
                "nvim-lua/plenary.nvim",
                "nvim-telescope/telescope-fzf-native.nvim",
                build = (build_cmd ~= "cmake") and "make"
                or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
                enabled = build_cmd ~= nil,
                config = function(plugin)
                    LazyVim.on_load("telescope.nvim", function()
                        local ok, err = pcall(require("telescope").load_extension, "fzf")
                        if not ok then
                            local lib = plugin.dir .. "/build/libfzf." .. (LazyVim.is_win() and "dll" or "so")
                            if not vim.uv.fs_stat(lib) then
                                LazyVim.warn("`telescope-fzf-native.nvim` not built. Rebuilding...")
                                require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
                                    LazyVim.info("Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim.")
                                end)
                            else
                                LazyVim.error("Failed to load `telescope-fzf-native.nvim`:\n" .. err)
                            end
                        end
                    end)
                end,
            },
        },
    },

    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        keys = function()
            local keys = {
                {
                    "<leader>ha",
                    function()
                        require("harpoon"):list():add()
                    end,
                    desc = "Harpoon File",
                },
                {
                    "<leader>hh",
                    function()
                        local harpoon = require("harpoon")
                        harpoon.ui:toggle_quick_menu(harpoon:list())
                    end,
                    desc = "Harpoon File",
                },
            }

            for i = 1, 5 do
                table.insert(keys, {
                    "<leader>" .. i,
                    function()
                        require("harpoon"):list():select(i)
                    end,
                    desc = "Harpoon to File " .. i,
                })
            end
            return keys
        end,
    },
{
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        -- "3rd/image.nvim", -- Optional image support in preview window
    },
    config = function ()
        require("neo-tree").setup({
            close_if_last_window = true,
            filesystem = {
                follow_current_file = true,
                hijack_netrw_behavior = "open_current",
                use_libuv_file_watcher = true, -- Automatically updates the tree
                filtered_items = {
                    hide_dotfiles = false,
                    hide_gitignored = true,
                },
                cwd_target = {
                    markers = { ".git", "env" }, -- Define project root markers
                    upward = true, -- Traverse upward to find the markers
                },
            },
            window = {
                position = "left",
                width = 30,
                mappings = {
                    ["l"] = "open",          -- Use `l` to open or expand directories
                    ["h"] = "close_node",    -- Use `h` to close directories
                }
            },
            default_component_configs = {
                indent = {
                    with_markers = true,
                    expanders = {
                        none = " ",
                        open = "▾",
                        closed = "▸",
                    },
                },
            },
        })
    end
}}
