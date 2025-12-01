require("config.setup")
require("config.lazy") -- also includes plugins
require("config.keymap")
require("config.filetype")
require("config.after")
vim.g.lazy_disable_warn_reload = true -- Suppress the re-sourcing warning
