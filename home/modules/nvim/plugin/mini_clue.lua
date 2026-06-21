require("mini.clue").setup({
  triggers = {
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "n", keys = "g" },
    { mode = "n", keys = "z" },
    { mode = "n", keys = "<C-w>" },
  },
  clues = {
    require("mini.clue").gen_clues.g(),
    require("mini.clue").gen_clues.z(),
    require("mini.clue").gen_clues.windows(),
  },
  window = { delay = 300 },
})
