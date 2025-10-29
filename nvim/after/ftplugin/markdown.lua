local set = vim.opt_local

local text_width = 75

set.conceallevel = 0
set.textwidth = text_width
set.colorcolumn = tostring(text_width)

-- Format options control automatic formatting behavior:
-- t: Auto-wrap text using textwidth
-- c: Auto-wrap comments using textwidth
-- q: Allow formatting comments with 'gq' command
-- j: Remove comment leader when joining lines
-- n: Recognize numbered lists when formatting
set.formatoptions = "tcqjn"
set.formatoptions = "cqjn"

-- soft wrapping lines visually
set.wrap = true
set.linebreak = true
set.breakindent = true
set.showbreak = "↪ "
