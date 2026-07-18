local servers = {
  {
    name = "jsonls",
    config = {
      cmd = { "vscode-json-language-server", "--stdio" },
      filetypes = { "json", "jsonc" },
      root_markers = { "package.json", "jsconfig.json", "tsconfig.json", ".git" },
      settings = {
        json = {
          format = { enable = true },
          schemas = {
            ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            ["https://json.schemastore.org/kustomization.json"] = "kustomization.yaml",
          },
        },
      },
    },
  },
  {
    name = "html_ls",
    config = {
      cmd = { "vscode-html-language-server", "--stdio" },
      filetypes = { "html" },
      root_markers = { "package.json", ".git" },
      settings = {
        html = {
          format = { enable = true },
          suggest = { html5 = true },
        },
      },
    },
  },
  {
    name = "css_ls",
    config = {
      cmd = { "vscode-css-language-server", "--stdio" },
      filetypes = { "css", "scss", "less" },
      root_markers = { "package.json", ".git" },
      settings = {
        css = {
          validate = true,
          lint = { unknownAtRules = "ignore" },
        },
      },
    },
  },
}

for _, server in ipairs(servers) do
  vim.lsp.config(server.name, server.config)
  vim.lsp.enable(server.name)
end
