-- Syntax highlighting: nvim-treesitter

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua",
    "nix",
    "go",
    "rust",
    "python",
    "typescript",
    "javascript",
    "yaml",
    "bash",
    "json",
    "toml",
    "html",
    "css",
    "markdown",
  },
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
})
