vim.lsp.config("oxfmt", {
  cmd = { "oxfmt", "--lsp" },
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  root_markers = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "package.json", "tsconfig.json", "jsconfig.json", ".git" },
})
vim.lsp.enable("oxfmt")
