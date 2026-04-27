# Dotfiles

This repo contains config files (dotfiles) to provide consistent
experience across devices. Managed by Nix.

## Contents

- zsh with customised [Powerlevel10k](https://github.com/romkatv/powerlevel10k) prompt and native Home Manager integrations
- [Alacritty](https://alacritty.org/)
- Neovim with [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- Tmux with [tpm](https://github.com/tmux-plugins/tpm)
- MacOS settings

## Installation

To install apps with Nix/Homebrew and set up various MacOS settings you need to
install Nix first:

```sh
sh <(curl -L https://nixos.org/nix/install)
```

To setup my MacBook I use [nix-darwin](https://github.com/LnL7/nix-darwin). To
install it run:

```sh
nix run --extra-experimental-features "nix-command flakes" nix-darwin -- switch --flake ./nix/darwin#book
```

To manage dotfiles I use [Home-manager](https://nixlang.wiki/nix/home-manager). It
set ups symlinks for all the files and configs programs.

## Inspiration

The inspiration for this setup came from the videos of
[Elliot Minns](https://github.com/elliottminns) and his
[Dreams of Autonomy](https://www.youtube.com/@dreamsofautonomy).
