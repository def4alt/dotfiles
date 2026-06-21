-- Load LSP configs from plugin/lsp/ subdirectory
-- (plugin/lsp/*.lua is NOT auto-loaded — only direct children of plugin/ are)

vim.cmd("runtime plugin/lsp/*.lua")
