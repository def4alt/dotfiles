vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  init_options = { hostInfo = "neovim" },
})
vim.lsp.enable("ts_ls")
