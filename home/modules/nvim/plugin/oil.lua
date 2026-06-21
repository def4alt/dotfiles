require("oil").setup({
  default_file_explorer = true,
  columns = { "icon" },
  keymaps = {
    ["<C-h>"] = false, ["<C-l>"] = false,
    ["<C-j>"] = false, ["<C-k>"] = false,
  },
  view_options = { show_hidden = true },
})
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Explorer" })
