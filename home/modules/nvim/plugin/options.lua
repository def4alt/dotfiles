-- Neovim options

local opt = vim.opt
local g = vim.g

-- Disable providers
g.loaded_node_provider = 0
g.loaded_perl_provider = 0

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.wrap = false

-- Hide mode indicator (lualine shows it)
opt.showmode = false

-- Mouse (disabled, terminal-only workflow)
opt.mouse = ""

-- LSP inlay hints (type hints, parameter names, etc.)
vim.lsp.inlay_hint.enable(true)

-- Completion
opt.completeopt = "menuone,noselect"

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Persistent undo
opt.undofile = true

-- OSC 52 clipboard for SSH/tmux
local function write_osc52(text)
  if not text or #text == 0 then
    return
  end
  local encoded = vim.base64.encode(text)
  local seq = string.format("\027]52;c;%s\007", encoded)

  if vim.fn.filewritable("/dev/fd/2") == 1 then
    vim.fn.writefile({ seq }, "/dev/fd/2", "b")
  else
    local ok, err = pcall(vim.fn.chansend, vim.v.stderr, seq)
    if not ok or err == nil or err <= 0 then
      io.stderr:write(seq)
      io.stderr:flush()
    end
  end
end

g.clipboard = {
  name = "OSC52",
  copy = {
    ["+"] = function(lines, _)
      if lines and #lines > 0 then
        write_osc52(table.concat(lines, "\n"))
      end
    end,
  },
  paste = {
    ["+"] = function()
      return {}
    end,
  },
}

-- Enable ui2 — experimental core UI redesign (Neovim 0.12+)
-- Routes LSP progress messages to the ephemeral msg window instead of cmdline
require("vim._core.ui2").enable({
  msg = {
    targets = { default = "cmd", progress = "msg" },
    msg = { timeout = 4000 },
  },
})

-- Python virtual env detection
local cwd = vim.fn.getcwd()
local venv_py = cwd .. "/.venv/bin/python"
if vim.fn.executable(venv_py) == 1 then
  g.python3_host_prog = venv_py
end
