-- Git diff signs in the gutter: mini.diff

require("mini.diff").setup({
  view = {
    style = "sign",
    signs = {
      add = "│",
      change = "│",
      delete = "_",
    },
  },
})
