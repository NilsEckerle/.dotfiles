-- LaTeX compilation script for Neovim

-- Set local options for LaTeX files
local set = vim.opt_local

-- LaTeX compilation function
local function compile_latex()
  -- Check if pdflatex exists before trying to run it
  local handle = io.popen("which pdflatex")
  local pdflatex_path = handle:read("*a"):gsub("\n", "")
  handle:close()
  
  if pdflatex_path == "" then
    vim.notify("pdflatex not found. Please install LaTeX.", vim.log.levels.ERROR)
    vim.notify("Recommended: Install the full LaTeX distribution with 'sudo apt-get install texlive-full'", vim.log.levels.WARN)
    return
  end
  
  local file = vim.fn.expand("%:p") -- Full file path
  local dir = vim.fn.expand("%:p:h") -- Get file's directory
  
  -- Run pdflatex in background, preserving your original approach
  vim.fn.jobstart({ pdflatex_path, "-output-directory", dir, file }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, _) end, -- Ignore stdout
    on_stderr = function(_, _) end, -- Ignore stderr
    detach = true, -- Run in background
  })
end

-- Set up autocmd to compile on save (preserving your current behavior)
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.tex",
  callback = compile_latex
})

-- You can add any additional LaTeX-specific settings below
-- set.textwidth = 80
-- set.spell = true
-- set.spelllang = "en_us"
