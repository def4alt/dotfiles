vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.showmode = false
vim.opt.mouse = ""
vim.opt.wildoptions = "pum"
vim.opt.completeopt = "menuone,noselect"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.undofile = true
vim.opt.cmdheight = 0
vim.opt.laststatus = 3

vim.lsp.inlay_hint.enable(true)

-- OSC 52 clipboard (SSH/tmux)
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
vim.g.clipboard = {
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

-- ui2: LSP progress → ephemeral msg window
require("vim._core.ui2").enable({
  msg = { targets = { default = "cmd", progress = "msg" }, msg = { timeout = 4000 } },
})

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
