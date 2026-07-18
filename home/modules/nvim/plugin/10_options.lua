vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.mouse = ""
vim.o.switchbuf = "usetab"
vim.o.undofile = true
vim.o.shada = "'100,<50,s10,:1000,/100,@100,h"

vim.o.breakindent = true
vim.o.cursorline = true
vim.o.cursorlineopt = "screenline,number"
vim.o.list = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.pumborder = "single"
vim.o.pumheight = 10
vim.o.ruler = false
vim.o.scrolloff = 8
vim.o.shortmess = "CFOSWaco"
vim.o.showmode = false
vim.o.showtabline = 0
vim.o.signcolumn = "yes"
vim.o.splitbelow = true
vim.o.splitkeep = "screen"
vim.o.splitright = true
vim.o.winborder = "single"
vim.o.wrap = false
vim.o.laststatus = 3
vim.o.fillchars = "eob: ,fold:╌"
vim.o.listchars = "extends:…,nbsp:␣,precedes:…,tab:> "

vim.o.foldlevel = 10
vim.o.foldmethod = "indent"
vim.o.foldnestmax = 10
vim.o.foldtext = ""

vim.o.expandtab = false
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.infercase = true
vim.o.shiftwidth = 2
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.virtualedit = "block"
vim.o.complete = ".,w,b,kspell"
vim.o.completeopt = "menuone,noselect,fuzzy,nosort"
vim.o.completetimeout = 100

Config.autocmd("FileType", "*", function()
  vim.opt_local.formatoptions:remove({ "c", "o" })
end, "Disable comment continuation")

Config.autocmd("LspAttach", "*", function(event)
  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if client and client:supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
  end
end, "Enable inlay hints")

vim.diagnostic.config({
  signs = { priority = 9999, severity = { min = "WARN", max = "ERROR" } },
  underline = true,
  virtual_lines = false,
  virtual_text = { current_line = true, severity = { min = "ERROR", max = "ERROR" } },
  update_in_insert = false,
})

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
