local ns = vim.api.nvim_create_namespace("golangci")
local root_markers = {
  ".golangci.yml",
  ".golangci.yaml",
  ".golangci.toml",
  ".golangci.json",
  "go.mod",
  ".git",
}
local seq = {}

local function is_enabled(bufnr)
  return vim.bo[bufnr].filetype == "go" and vim.fn.executable("golangci-lint") == 1 and vim.fn.executable("go") == 1
end

local function parse(stdout, filename)
  if not stdout or stdout == "" then
    return {}
  end
  local ok, decoded = pcall(vim.json.decode, stdout)
  if not ok or type(decoded) ~= "table" or type(decoded.Issues) ~= "table" then
    return {}
  end

  local diagnostics = {}
  for _, item in ipairs(decoded.Issues) do
    local pos = item.Pos or {}
    if pos.Filename == filename then
      table.insert(diagnostics, {
        lnum = math.max((pos.Line or 1) - 1, 0),
        col = math.max((pos.Column or 1) - 1, 0),
        severity = vim.diagnostic.severity.WARN,
        source = "golangci-lint",
        code = item.FromLinter,
        message = item.Text or "golangci-lint",
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

  vim.system({
    "golangci-lint",
    "run",
    "--allow-serial-runners",
    "--path-mode",
    "abs",
    "--output.json.path",
    "stdout",
    "--max-issues-per-linter",
    "0",
    "--max-same-issues",
    "0",
    name,
  }, { cwd = root, text = true }, function(result)
    if not vim.api.nvim_buf_is_valid(bufnr) or seq[bufnr] ~= current then
      return
    end
    local diagnostics = parse(result.stdout, name)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.diagnostic.set(ns, bufnr, diagnostics)
      end
    end)
  end)
end

vim.api.nvim_create_user_command("GolangciLint", function(args)
  lint(args.buf)
end, { desc = "Run golangci-lint for current buffer" })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("golangci", { clear = true }),
  callback = function(args)
    lint(args.buf)
  end,
})
