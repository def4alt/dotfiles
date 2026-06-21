vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luacheckrc", ".stylua.toml" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false },
    },
  },
})
vim.lsp.enable("lua_ls")
