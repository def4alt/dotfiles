-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.mouse = ""
opt.wrap = true
opt.textwidth = 80
opt.clipboard = ""

local cwd = vim.fn.getcwd()
local venv_py = cwd .. "/.venv/bin/python"
if vim.fn.executable(venv_py) == 1 then
  vim.g.python3_host_prog = venv_py
end
