local fzf = require("fzf-lua")
fzf.setup({})

local map = vim.keymap.set
map("n", "<leader>ff", function() fzf.files() end,        { desc = "Find files" })
map("n", "<leader>fg", function() fzf.grep() end,          { desc = "Live grep" })
map("n", "<leader>fb", function() fzf.buffers() end,       { desc = "Buffers" })
map("n", "<leader>fh", function() fzf.help_tags() end,     { desc = "Help" })
map("n", "<leader>fo", function() fzf.oldfiles() end,      { desc = "Recent files" })
map("n", "<leader>fc", function() fzf.git_status() end,    { desc = "Git status" })
map("n", "<leader>fd", function() fzf.diagnostics_document() end, { desc = "Diagnostics (buffer)" })
map("n", "<leader>fD", function() fzf.diagnostics_workspace() end, { desc = "Diagnostics (workspace)" })
map("n", "<leader>f.", function() fzf.resume() end,        { desc = "Resume" })
map("n", "<leader>f?", function() fzf.builtin() end,        { desc = "Picker list" })
