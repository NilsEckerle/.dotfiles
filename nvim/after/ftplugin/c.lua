-- after/ftplugin/c.lua
local function detect_cpp_project()
	-- Check for C++ specific files in the project
	local root = vim.fn.getcwd()

	-- Look for C++ source files
	local cpp_files = vim.fn.glob(root .. "/**/*.cpp", false, true)
	local cxx_files = vim.fn.glob(root .. "/**/*.cxx", false, true)
	local cc_files = vim.fn.glob(root .. "/**/*.cc", false, true)

	if #cpp_files > 0 or #cxx_files > 0 or #cc_files > 0 then
		return true
	end

	-- Check for C++ specific build files
	if vim.fn.filereadable(root .. "/CMakeLists.txt") == 1 then
		local cmake = vim.fn.readfile(root .. "/CMakeLists.txt")
		for _, line in ipairs(cmake) do
			if line:match("CXX") or line:match("C++") or line:match("cpp") then
				return true
			end
		end
	end

	return false
end

-- Only run this for .h files
if vim.fn.expand("%:e") == "h" then
	if detect_cpp_project() then
		vim.bo.filetype = "cpp"
		return -- Exit early, don't run C-specific config
	end
end

local set = vim.opt_local
local floating_term = require("floating-terminal")

local cflags = "-g -Wall "

local compile_and_run = function()
	local file = vim.fn.expand("%:p")
	local cmd = "g++ -o main " .. cflags .. vim.fn.shellescape(file) .. " && chmod +x main && ./main"
	floating_term.run_command(cmd)
end

local compile_only = function()
	local file = vim.fn.expand("%:p")
	local cmd = "gcc -o main " .. cflags .. vim.fn.shellescape(file)
	floating_term.run_command(cmd)
end

local run_main = function()
	floating_term.run_command("./main")
end

-- C-specific keymaps
vim.keymap.set("n", "<leader>cR", compile_and_run, { desc = "Compile and run only this file", buffer = true })
vim.keymap.set(
	"n",
	"<leader>cC",
	compile_only,
	{ desc = "Compile only this file to main and make it executable", buffer = true }
)
vim.keymap.set("n", "<leader>cX", run_main, { desc = "Run already compiled main file", buffer = true })

vim.keymap.set("n", "<leader>make", "<cmd>:make build<cr>", { buffer = true })
vim.keymap.set("n", "<leader>clean", "<cmd>:make clean<cr>", { buffer = true })
vim.keymap.set("n", "<leader>run", function()
	floating_term.send_command("make run")
end, { buffer = true })

-- Terminal toggle keymap
vim.keymap.set("n", "<leader>t", floating_term.toggle, { desc = "Toggle Floating Terminal" })
