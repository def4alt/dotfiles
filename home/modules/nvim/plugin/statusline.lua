local M = {}

local mode_names = {
  n = "NORMAL",
  no = "N-PENDING",
  v = "VISUAL",
  V = "V-LINE",
  ["\022"] = "V-BLOCK",
  s = "SELECT",
  S = "S-LINE",
  ["\019"] = "S-BLOCK",
  i = "INSERT",
  ic = "INSERT",
  R = "REPLACE",
  Rv = "V-REPLACE",
  c = "COMMAND",
  cv = "COMMAND",
  ce = "COMMAND",
  r = "PROMPT",
  rm = "MORE",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",
  t = "TERMINAL",
}

function M.mode()
  return mode_names[vim.fn.mode(1)] or vim.fn.mode(1)
end

function M.filename()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return "[No Name]"
  end
  return vim.fn.fnamemodify(name, ":~")
end

function M.diagnostics()
  local counts = {
    errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }),
    warns = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }),
    infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO }),
    hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT }),
  }

  local parts = {}
  if counts.errors > 0 then
    table.insert(parts, "E:" .. counts.errors)
  end
  if counts.warns > 0 then
    table.insert(parts, "W:" .. counts.warns)
  end
  if counts.infos > 0 then
    table.insert(parts, "I:" .. counts.infos)
  end
  if counts.hints > 0 then
    table.insert(parts, "H:" .. counts.hints)
  end

  return #parts > 0 and table.concat(parts, " ") or "OK"
end

_G.Statusline = M
vim.opt.statusline = table.concat({
  " ",
  "%{v:lua.Statusline.mode()}",
  " | ",
  "%{v:lua.Statusline.filename()}",
  " | ",
  "%{v:lua.Statusline.diagnostics()}",
  "%=",
  "%y",
  " ",
})
