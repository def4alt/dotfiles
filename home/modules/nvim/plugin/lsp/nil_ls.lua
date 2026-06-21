vim.lsp.config("nil", {
  cmd = { "nil" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", "shell.nix", "default.nix" },
  settings = { ["nil"] = { formatting = { command = { "nixfmt" } } } },
})
vim.lsp.enable("nil")
