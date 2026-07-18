local config_dir = vim.fs.normalize(vim.fn.stdpath("config"))
local library = vim.tbl_filter(function(path)
  return vim.fs.normalize(path) ~= config_dir
end, vim.api.nvim_get_runtime_file("", true))

return {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        checkThirdParty = false,
        library = library,
      },
      telemetry = { enable = false },
    },
  },
}
