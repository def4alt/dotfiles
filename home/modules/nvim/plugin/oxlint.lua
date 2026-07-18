local ns = vim.api.nvim_create_namespace("oxlint")
local ft = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
}
local root_markers = {
  ".oxlintrc.json",
  ".oxlintrc.jsonc",
  "oxlint.json",
  "oxlint.jsonc",
  "package.json",
  "tsconfig.json",
  "jsconfig.json",
  ".git",
}
local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
}
local seq = {}

local function is_enabled(bufnr)
  return ft[vim.bo[bufnr].filetype] and vim.fn.executable("oxlint") == 1
end

local function parse(stdout)
  if not stdout or stdout == "" then
    return {}
  end
  local ok, decoded = pcall(vim.json.decode, stdout)
  if not ok or type(decoded) ~= "table" or type(decoded.diagnostics) ~= "table" then
    return {}
  end

  local diagnostics = {}
  for _, item in ipairs(decoded.diagnostics) do
    local label = item.labels and item.labels[1] or nil
    local span = label and label.span or nil
    if span then
      local message = item.message or "oxlint"
      if label.label and label.label ~= "" then
        message = message .. "\n" .. label.label
      end
      if item.help and item.help ~= "" then
        message = message .. "\n" .. item.help
      end
      table.insert(diagnostics, {
        lnum = math.max((span.line or 1) - 1, 0),
        col = math.max((span.column or 1) - 1, 0),
        end_lnum = math.max((span.line or 1) - 1, 0),
        end_col = math.max((span.column or 1) - 1 + math.max(span.length or 1, 1), 0),
        severity = severity_map[item.severity] or vim.diagnostic.severity.WARN,
        source = "oxlint",
        code = item.code,
        message = message,
      })
    end
  end

  return diagnostics
end

local function lint(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  if not is_enabled(bufnr) then
    vim.diagnostic.reset(ns, bufnr)
    return
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    vim.diagnostic.reset(ns, bufnr)
    return
  end

  local root = vim.fs.root(name, root_markers) or vim.fs.dirname(name)
  seq[bufnr] = (seq[bufnr] or 0) + 1
  local current = seq[bufnr]

  vim.system({ "oxlint", "--format", "json", name }, { cwd = root, text = true }, function(result)
    if not vim.api.nvim_buf_is_valid(bufnr) or seq[bufnr] ~= current then
      return
    end
    local diagnostics = parse(result.stdout)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.diagnostic.set(ns, bufnr, diagnostics)
      end
    end)
  end)
end

vim.api.nvim_create_user_command("Oxlint", function(args)
  lint(args.buf)
end, { desc = "Run oxlint for current buffer" })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("oxlint", { clear = true }),
  callback = function(args)
    lint(args.buf)
  end,
})
