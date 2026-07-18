require("kanagawa").setup({
  compile = false,
  theme = "dragon",
  background = { dark = "dragon" },
})
vim.cmd.colorscheme("kanagawa-dragon")

require("oil").setup({
  default_file_explorer = true,
  columns = { "icon" },
  keymaps = {
    ["<C-h>"] = false,
    ["<C-j>"] = false,
    ["<C-k>"] = false,
    ["<C-l>"] = false,
  },
  view_options = { show_hidden = true },
})

require("fzf-lua").setup({
  winopts = { border = "single", preview = { border = "single" } },
})

require("miniharp").setup()

local languages = {
  "bash",
  "css",
  "go",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "nix",
  "python",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "vimdoc",
  "yaml",
  "zig",
}
local treesitter = require("nvim-treesitter")
if treesitter.install then
  treesitter.setup()
  for _, queries in ipairs(vim.api.nvim_get_runtime_file("runtime/queries", true)) do
    vim.opt.runtimepath:prepend(vim.fs.dirname(queries))
  end
end

local missing = vim.tbl_filter(function(language)
  return #vim.api.nvim_get_runtime_file("parser/" .. language .. ".*", false) == 0
end, languages)
if #missing > 0 then
  if treesitter.install then
    treesitter.install(missing)
  else
    vim.schedule(function()
      vim.cmd("TSInstall " .. table.concat(missing, " "))
    end)
  end
end

local filetypes = {}
for _, language in ipairs(languages) do
  vim.list_extend(filetypes, vim.treesitter.language.get_filetypes(language))
end
Config.autocmd("FileType", filetypes, function(event)
  vim.treesitter.start(event.buf)
end, "Enable Treesitter")

vim.lsp.enable({
  "bashls",
  "cssls",
  "gopls",
  "html",
  "jsonls",
  "lua_ls",
  "marksman",
  "nixd",
  "oxlint",
  "pyright",
  "ruff",
  "rust_analyzer",
  "vtsls",
  "yamlls",
  "zls",
})

require("conform").setup({
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
  formatters_by_ft = {
    bash = { "shfmt" },
    css = { "oxfmt" },
    go = { "gofumpt" },
    html = { "oxfmt" },
    javascript = { "oxfmt" },
    javascriptreact = { "oxfmt" },
    json = { "oxfmt" },
    jsonc = { "oxfmt" },
    lua = { "stylua" },
    markdown = { "oxfmt" },
    nix = { "nixfmt" },
    python = { "ruff_format" },
    rust = { "rustfmt" },
    scss = { "oxfmt" },
    sh = { "shfmt" },
    typescript = { "oxfmt" },
    typescriptreact = { "oxfmt" },
    yaml = { "yamlfmt" },
    zig = { "zigfmt" },
  },
})
