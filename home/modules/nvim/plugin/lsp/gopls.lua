-- Go LSP: gopls

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod" },
  root_markers = { "go.mod", "go.sum", ".git" },
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        unusedwrite = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})

vim.lsp.enable("gopls")
