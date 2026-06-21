-- Fuzzy picker: mini.pick

require("mini.pick").setup({
  options = {
    source = {
      show_hidden = true,
    },
  },
  window = {
    prompt = "  ",
  },
})

-- Keymaps
local map = vim.keymap.set
map("n", "<leader>ff", "<cmd>Pick files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Pick grep<cr>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Pick buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Pick help<cr>", { desc = "Help tags" })
map("n", "<leader>fo", "<cmd>Pick oldfiles<cr>", { desc = "Recent files" })
map("n", "<leader>fd", "<cmd>Pick diagnostics<cr>", { desc = "Diagnostics" })
