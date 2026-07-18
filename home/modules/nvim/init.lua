_G.Config = {}

local group = vim.api.nvim_create_augroup("minimax-config", { clear = true })

Config.autocmd = function(event, pattern, callback, desc)
  vim.api.nvim_create_autocmd(event, {
    group = group,
    pattern = pattern,
    callback = callback,
    desc = desc,
  })
end

Config.on_packchanged = function(plugin_name, kinds, callback)
  Config.autocmd("PackChanged", "*", function(event)
    local data = event.data
    if data.spec.name ~= plugin_name or not vim.tbl_contains(kinds, data.kind) then
      return
    end
    if not data.active then
      vim.cmd.packadd(plugin_name)
    end
    callback(data)
  end, "Update " .. plugin_name)
end

Config.on_packchanged("nvim-treesitter", { "update" }, function()
  vim.cmd("TSUpdate")
end)

vim.pack.add({
  "https://github.com/nvim-mini/mini.ai",
  "https://github.com/nvim-mini/mini.clue",
  "https://github.com/nvim-mini/mini.comment",
  "https://github.com/saghen/blink.lib",
  "https://github.com/saghen/blink.cmp",
  "https://github.com/nvim-mini/mini.diff",
  "https://github.com/nvim-mini/mini-git",
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-mini/mini.notify",
  "https://github.com/nvim-mini/mini.pairs",
  "https://github.com/nvim-mini/mini.starter",
  "https://github.com/nvim-mini/mini.statusline",
  "https://github.com/nvim-mini/mini.surround",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/vieitesss/miniharp.nvim",
  "https://github.com/rebelot/kanagawa.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/rafamadriz/friendly-snippets",
})
