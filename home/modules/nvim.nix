{config, pkgs, lib, ...}:
let
  treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;

  treesitterGrammars = pkgs.symlinkJoin {
    name = "nvim-treesitter-grammars";
    paths = treesitter.dependencies;
  };

  plugins = with pkgs.vimPlugins; [
    blink-cmp
    bufferline-nvim
    conform-nvim
    flash-nvim
    friendly-snippets
    fzf-lua
    gitsigns-nvim
    grug-far-nvim
    lazydev-nvim
    lazy-nvim
    LazyVim
    lualine-nvim
    mini-ai
    mini-icons
    mini-pairs
    neo-tree-nvim
    noice-nvim
    nui-nvim
    nvim-lint
    nvim-lspconfig
    nvim-treesitter
    nvim-treesitter-textobjects
    nvim-ts-autotag
    persistence-nvim
    plenary-nvim
    snacks-nvim
    todo-comments-nvim
    tokyonight-nvim
    trouble-nvim
    ts-comments-nvim
    which-key-nvim
  ];

  mkEntryFromDrv = drv:
    if lib.isDerivation drv then {
      name = lib.getName drv;
      path = drv;
    } else drv;

  lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
in {
  programs.neovim = {
    enable = true;
    withRuby = true;
    withPython3 = true;

    # Tools and LSP servers available on $PATH for Neovim.
    extraPackages = with pkgs; [
      # general dependencies
      git
      lazygit
      ripgrep
      fzf
      fd
      tree-sitter

      # LUA
      lua-language-server
      stylua

      # NIX
      nil
      nixfmt
      statix
    ];

    # Only lazy-nvim itself is loaded as a Neovim plugin.
    plugins = with pkgs.vimPlugins; [ lazy-nvim ];

    extraLuaConfig = ''
      require("lazy").setup({
        defaults = {
          lazy = true,
          version = false,
        },
        dev = {
          path = "${lazyPath}",
          patterns = { "." },
          fallback = true,
        },
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },

          -- disable mason.nvim, use programs.neovim.extraPackages
          { "mason-org/mason-lspconfig.nvim", enabled = false },
          { "mason-org/mason.nvim", enabled = false },

          -- import/override with your plugins
          { import = "plugins" },

          {
            "nvim-treesitter/nvim-treesitter",
            build = "",
            opts = {
              install_dir = "${treesitterGrammars}",
            },
          },
        },
        install = { colorscheme = { "tokyonight-night" } },
        checker = { enabled = false },
      })
    '';
  };

  # Normal LazyVim config here, like this: https://github.com/LazyVim/starter/tree/main/lua
  # mkOutOfStoreSymlink is used instead of a regular source so the files
  # aren't copied into the Nix store. This keeps them writable, allowing
  # you to edit your Lua config and see changes immediately without rebuilding.
  xdg.configFile."nvim/lazyvim.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/modules/nvim/lazyvim.json";
    force = true;
  };

  xdg.configFile."nvim/lua" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/modules/nvim/lua";
    recursive = true;
    force = true;
  };
}
