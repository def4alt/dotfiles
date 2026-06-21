require("miniharp").setup({
  autoload = true, autosave = true, notifications = true,
  ui = { position = "center", show_hints = true, enter = true },
})
local map = vim.keymap.set
map("n", "<leader>m", function() require("miniharp").toggle_file() end, { desc = "Toggle mark" })
map("n", "<C-n>",     function() require("miniharp").next() end,        { desc = "Next mark" })
map("n", "<C-p>",     function() require("miniharp").prev() end,        { desc = "Prev mark" })
map("n", "<leader>l", function() require("miniharp").show_list() end,   { desc = "Marks list" })
for i = 1, 9 do
  map("n", "<leader>" .. i, function() require("miniharp").go_to(i) end, { desc = "Mark " .. i })
end
