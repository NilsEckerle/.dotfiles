-- lua/floating-terminal.lua
local M = {}

-- Store terminal state
local terminal_state = {
	buf = nil,
	win = nil,
	job_id = nil,
	is_open = false,
}

-- Configuration
local config = {
	width_ratio = 0.8,
	height_ratio = 0.8,
	border = "rounded",
}

-- Create or get existing terminal buffer
local function get_or_create_terminal()
	if terminal_state.buf and vim.api.nvim_buf_is_valid(terminal_state.buf) then
		return terminal_state.buf
	end

	-- Create new terminal buffer
	terminal_state.buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(terminal_state.buf, "bufhidden", "hide")

	return terminal_state.buf
end

-- Calculate window dimensions
local function get_window_config()
	local width = math.floor(vim.o.columns * config.width_ratio)
	local height = math.floor(vim.o.lines * config.height_ratio)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	return {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = config.border,
	}
end

-- Open the floating terminal
function M.open()
	if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
		-- Focus existing window
		vim.api.nvim_set_current_win(terminal_state.win)
		return
	end

	local buf = get_or_create_terminal()
	local win_config = get_window_config()

	terminal_state.win = vim.api.nvim_open_win(buf, true, win_config)
	terminal_state.is_open = true

	-- Set window-specific options
	vim.api.nvim_win_set_option(terminal_state.win, "winhl", "Normal:Normal")

	-- If no job is running, start a shell
	if not terminal_state.job_id then
		terminal_state.job_id = vim.fn.termopen(vim.o.shell, {
			on_exit = function()
				terminal_state.job_id = nil
			end,
		})
	end

	-- Set up window close autocommand
	vim.api.nvim_create_autocmd({ "WinClosed" }, {
		pattern = tostring(terminal_state.win),
		callback = function()
			terminal_state.is_open = false
			terminal_state.win = nil
		end,
		once = true,
	})

	-- vim.cmd("startinsert")
end

-- Close the floating terminal
function M.close()
	if terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
	end
	terminal_state.is_open = false
	terminal_state.win = nil
end

-- Toggle the floating terminal
function M.toggle()
	if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
		M.close()
	else
		M.open()
	end
end

-- Send Ctrl+C to interrupt current process and clear terminal
local function send_interrupt()
	if terminal_state.job_id then
		-- Send Ctrl+C (ASCII 3)
		vim.fn.chansend(terminal_state.job_id, "\x03")
		-- Wait for interrupt to take effect, then send clear command
		vim.defer_fn(function()
			if terminal_state.job_id then
				vim.fn.chansend(terminal_state.job_id, "clear\r")
			end
		end, 100)
	end
end

-- Send command to terminal
function M.send_command(cmd)
	if not terminal_state.job_id then
		-- Open terminal first if it doesn't exist
		M.open()
		-- Wait a bit for terminal to be ready
		vim.defer_fn(function()
			if terminal_state.job_id then
				vim.fn.chansend(terminal_state.job_id, cmd .. "\r")
			end
		end, 100)
	else
		-- Send Ctrl+C first to interrupt any running command
		send_interrupt()
		-- Wait a moment then send the new command
		vim.defer_fn(function()
			if terminal_state.job_id then
				vim.fn.chansend(terminal_state.job_id, cmd .. "\r")
			end
		end, 100)
		-- Optionally open the terminal to show the command output
		if not terminal_state.is_open then
			M.open()
		end
	end
end

-- Run command in terminal (opens terminal and sends command)
function M.run_command(cmd)
	M.open()
	vim.defer_fn(function()
		M.send_command(cmd)
	end, 100)
end

-- Kill the terminal process
function M.kill()
	if terminal_state.job_id then
		vim.fn.jobstop(terminal_state.job_id)
		terminal_state.job_id = nil
	end
end

-- Get terminal state info
function M.get_state()
	return {
		is_open = terminal_state.is_open,
		has_job = terminal_state.job_id ~= nil,
		buf_valid = terminal_state.buf and vim.api.nvim_buf_is_valid(terminal_state.buf),
		win_valid = terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win),
	}
end

return M
