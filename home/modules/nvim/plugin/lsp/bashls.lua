-- Bash LSP: bash-language-server

vim.lsp.config("bashls", {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash", "zsh" },
  root_markers = { ".shellcheckrc", ".git" },
})

vim.lsp.enable("bashls")
