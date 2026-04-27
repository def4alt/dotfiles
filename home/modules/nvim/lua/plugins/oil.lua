return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },

  {
    "stevearc/oil.nvim",
    keys = {
      { "<leader>e", "<cmd>Oil<cr>", desc = "Explorer" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = true,
    },
    init = function(plugin)
      if vim.fn.argc() == 1 then
        local argv = tostring(vim.fn.argv(0))
        local stat = vim.loop.fs_stat(argv)
        local remote_dir_args = vim.startswith(argv, "ssh")
          or vim.startswith(argv, "sftp")
          or vim.startswith(argv, "scp")

        if (stat and stat.type == "directory") or remote_dir_args then
          require("lazy").load({ plugins = { plugin.name } })
        end
      end

      if not require("lazy.core.config").plugins[plugin.name]._.loaded then
        vim.api.nvim_create_autocmd("BufNew", {
          callback = function()
            if vim.fn.isdirectory(vim.fn.expand("<afile>")) == 1 then
              require("lazy").load({ plugins = { plugin.name } })
              return true
            end
          end,
        })
      end
    end,
  },
}
