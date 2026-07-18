# Configuration review

## Dependency policy

- `flake.lock` pins all Nix inputs; update it intentionally with `nix flake update`.
- CLI tools and language servers come from Nixpkgs rather than mutable global installers.
- GUI applications unavailable or unsuitable in Nixpkgs are managed by Homebrew casks on macOS.
- Neovim plugins use native `vim.pack` Git sources and are not pinned by this repository. This favors simple updates over fully reproducible editor plugins.

## Security notes

The repository contains public SSH keys and an age recipient. Those are public identifiers, not private key material.

## Intentional exceptions

- `home/modules/nvim.nix` uses an out-of-store symlink so Lua configuration remains editable without rebuilding. The repository must therefore live at `~/dotfiles`.
- Rectangle's exported `RectangleConfig.json` keeps the application's original filename and formatting.
- Homebrew manages macOS GUI applications while Nix manages command-line packages.
