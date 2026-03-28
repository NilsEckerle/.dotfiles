return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- ================================================================
			-- DAP UI SETUP
			-- ================================================================

			-- local layout = require("dap-layout.default")
			local layout = require("plugins.dap-layout.nils")
			dapui.setup(layout)

			-- Virtual text setup
			require("nvim-dap-virtual-text").setup({
				enabled = true,
				enabled_commands = true,
				highlight_changed_variables = true,
				highlight_new_as_changed = false,
				show_stop_reason = true,
				commented = false,
			})

			-- ================================================================
			-- C++ ADAPTER CONFIGURATION (GDB)
			-- ================================================================
			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "-i", "dap" },
			}

			-- ================================================================
			-- C++ ADAPTER CONFIGURATION (LLDB)
			-- ================================================================
			dap.adapters.lldb = {
				type = "executable",
				command = "/usr/sbin/lldb-dap",
				name = "lldb",
			}

			-- ================================================================
			-- HELPER FUNCTIONS
			-- ================================================================
			-- Find the build directory
			local function find_build_dir()
				local cwd = vim.fn.getcwd()
				local build_dirs = { "build", "Build", "BUILD", "cmake-build-debug", "out/build" }

				for _, dir in ipairs(build_dirs) do
					local path = cwd .. "/" .. dir
					if vim.fn.isdirectory(path) == 1 then
						return path
					end
				end

				return cwd .. "/build"
			end

			-- Find executable in build directory
			local function find_executable()
				local build_dir = find_build_dir()
				local executables = vim.fn.glob(build_dir .. "/*", false, true)

				-- Filter for executable files
				local execs = {}
				for _, file in ipairs(executables) do
					if vim.fn.executable(file) == 1 and not file:match("%.so$") and not file:match("%.a$") then
						table.insert(execs, file)
					end
				end

				-- If only one executable, return it
				if #execs == 1 then
					return execs[1]
				end

				-- Otherwise, prompt user
				return vim.fn.input({
					prompt = "Path to executable: ",
					default = build_dir .. "/",
					completion = "file",
				})
			end

			-- Get project root directory
			local function get_project_root()
				-- Look for CMakeLists.txt
				local cmake = vim.fn.findfile("CMakeLists.txt", ".;")
				if cmake ~= "" then
					return vim.fn.fnamemodify(cmake, ":h")
				end
				return vim.fn.getcwd()
			end

			-- ================================================================
			-- C++ DEBUG CONFIGURATIONS
			-- ================================================================
			dap.configurations.cpp = {
				{
					name = "Launch (LLDB)",
					type = "lldb",
					request = "launch",
					program = function()
						return vim.fn.input({
							prompt = "Path to executable: ",
							default = find_build_dir() .. "/",
							completion = "file",
						})
					end,
					cwd = get_project_root,
					stopOnEntry = false,
					args = {},
					runInTerminal = false,
				},
				{
					name = "Launch with arguments (LLDB)",
					type = "lldb",
					request = "launch",
					program = function()
						return vim.fn.input({
							prompt = "Path to executable: ",
							default = find_build_dir() .. "/",
							completion = "file",
						})
					end,
					args = function()
						local args_string = vim.fn.input("Arguments: ")
						return vim.split(args_string, " +")
					end,
					cwd = get_project_root,
					stopAtBeginningOfMainSubprogram = false,
				},
				{
					name = "Launch (GDB) - Manual",
					type = "gdb",
					request = "launch",
					program = function()
						return vim.fn.input({
							prompt = "Path to executable: ",
							default = find_build_dir() .. "/",
							completion = "file",
						})
					end,
					cwd = get_project_root,
					stopAtBeginningOfMainSubprogram = false,
				},
				{
					name = "Launch with arguments (GDB)",
					type = "gdb",
					request = "launch",
					program = find_executable,
					args = function()
						local args_string = vim.fn.input("Arguments: ")
						return vim.split(args_string, " +")
					end,
					cwd = get_project_root,
					stopAtBeginningOfMainSubprogram = false,
				},
				{
					name = "Attach to process (GDB)",
					type = "gdb",
					request = "attach",
					processId = require("dap.utils").pick_process,
				},
			}

			-- Use same config for C
			dap.configurations.c = dap.configurations.cpp

			-- Use same config for oil.nvim file browser
			dap.configurations.oil = dap.configurations.cpp

			-- ================================================================
			-- AUTO-OPEN/CLOSE DAP UI
			-- ================================================================
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			-- ================================================================
			-- CMAKE BUILD COMMAND
			-- ================================================================
			-- Command to rebuild with debug symbols
			vim.api.nvim_create_user_command("DapCMakeBuildDebug", function()
				local project_root = get_project_root()
				local build_dir = find_build_dir()

				vim.notify("Building with debug symbols...", vim.log.levels.INFO)

				-- Create build directory if it doesn't exist
				vim.fn.mkdir(build_dir, "p")

				-- Configure and build
				local cmd = string.format(
					"cd %s && cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -S %s -B %s && cmake --build %s",
					project_root,
					project_root,
					build_dir,
					build_dir
				)

				vim.fn.system(cmd)

				if vim.v.shell_error == 0 then
					vim.notify("Build successful!", vim.log.levels.INFO)
				else
					vim.notify("Build failed! Check :messages", vim.log.levels.ERROR)
				end
			end, {})

			-- ================================================================
			-- KEYMAPS
			-- ================================================================
			local map = vim.keymap.set

			-- Start/Stop debugging
			map("n", "<F5>", dap.continue, { noremap = true, silent = true, desc = "DAP: Start/Continue debugging" })
			map("n", "<F17>", dap.terminate, { noremap = true, silent = true, desc = "DAP: Stop debugging (Shift+F5)" })
			map(
				"n",
				"<leader><F5>",
				dap.run_last,
				{ noremap = true, silent = true, desc = "DAP: Rerun last debug configuration" }
			)

			-- Stepping
			map("n", "<C-j>", dap.step_over, { noremap = true, silent = true, desc = "DAP: Step over" })
			map("n", "<C-l>", dap.step_into, { noremap = true, silent = true, desc = "DAP: Step into" })
			map("n", "<C-h>", dap.step_out, { noremap = true, silent = true, desc = "DAP: Step out" })

			-- Breakpoints
			map(
				"n",
				"<leader>db",
				dap.toggle_breakpoint,
				{ noremap = true, silent = true, desc = "DAP: Toggle breakpoint" }
			)
			map("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { noremap = true, silent = true, desc = "DAP: Set conditional breakpoint" })
			map("n", "<leader>dL", function()
				dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end, { noremap = true, silent = true, desc = "DAP: Set log point" })
			map(
				"n",
				"<leader>dc",
				dap.clear_breakpoints,
				{ noremap = true, silent = true, desc = "DAP: Clear all breakpoints" }
			)

			-- UI Controls
			map("n", "<leader>du", dapui.toggle, { noremap = true, silent = true, desc = "DAP: Toggle debug UI" })
			map("n", "<leader>dr", dap.repl.open, { noremap = true, silent = true, desc = "DAP: Open REPL" })
			map(
				"n",
				"<leader>dl",
				dap.run_last,
				{ noremap = true, silent = true, desc = "DAP: Run last configuration" }
			)

			-- Hover and eval
			map({ "n", "v" }, "<leader>dh", function()
				require("dap.ui.widgets").hover()
			end, { noremap = true, silent = true, desc = "DAP: Hover / Inspect variable" })
			map({ "n", "v" }, "<leader>dp", function()
				require("dap.ui.widgets").preview()
			end, { noremap = true, silent = true, desc = "DAP: Preview value" })

			-- Frames and scopes
			map("n", "<leader>df", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end, { noremap = true, silent = true, desc = "DAP: Show stack frames" })
			map("n", "<leader>ds", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.scopes)
			end, { noremap = true, silent = true, desc = "DAP: Show scopes/variables" })

			-- CMake build
			map(
				"n",
				"<leader>dC",
				"<cmd>DapCMakeBuildDebug<CR>",
				{ noremap = true, silent = true, desc = "DAP: CMake build with debug symbols" }
			)

			-- ================================================================
			-- SIGNS (Breakpoint icons)
			-- ================================================================
			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
			vim.fn.sign_define(
				"DapBreakpointCondition",
				{ text = "◆", texthl = "DapBreakpoint", linehl = "", numhl = "" }
			)
			vim.fn.sign_define(
				"DapBreakpointRejected",
				{ text = "○", texthl = "DapBreakpoint", linehl = "", numhl = "" }
			)
			vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
			vim.fn.sign_define(
				"DapStopped",
				{ text = "→", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" }
			)

			-- ================================================================
			-- HIGHLIGHTS
			-- ================================================================
			vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e51400" })
			vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })
			vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379" })
			vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2e3440" })
		end,
	},
}
