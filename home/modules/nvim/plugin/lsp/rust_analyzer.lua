-- Rust LSP: rust-analyzer

vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "Cargo.lock" },
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = true,
      diagnostics = { disabled = { "unresolved-proc-macro" } },
      procMacro = { enable = true },
    },
  },
})

vim.lsp.enable("rust_analyzer")
