# Dotfiles

Declarative configuration for `alderbook`, an Apple silicon Mac managed with nix-darwin and Home Manager.

## Repository layout

```text
.
├── config/               # Application exports not managed directly by Nix
├── home/                 # Shared Home Manager configuration
│   └── modules/          # One module per managed program
├── hosts/
│   └── alderbook/        # Host-specific nix-darwin configuration
├── lib/                  # Flake construction helpers
├── flake.nix             # Inputs and host outputs
└── flake.lock            # Pinned dependencies
```

## Bootstrap

Install Nix with flakes enabled. On macOS, the Determinate Systems installer is a convenient option:

```sh
curl --proto '=https' --tlsv1.2 -sSf \
  -L https://install.determinate.systems/nix | sh -s -- install
```

Clone this repository at `~/dotfiles`, which is the path used by the writable Neovim plugin configuration:

```sh
git clone git@github.com:def4alt/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Apply the host configuration:

```sh
sudo nix run nix-darwin -- switch --flake .#alderbook
```

The `update` shell alias runs the corresponding rebuild command after bootstrap.

## Secrets

Secrets are encrypted with [SOPS](https://getsops.io/) and age. Place the matching age identity at:

```text
~/.config/sops/age/keys.txt
```

Never format `secrets.yaml` files manually: changing encrypted payloads without SOPS invalidates their MAC. The pre-commit configuration excludes them from YAML formatters.

## Maintenance

```sh
nix flake update                       # update pinned flake inputs
nix fmt                               # format Nix files
nix flake check --all-systems          # evaluate every host/output
nix run nixpkgs#deadnix -- --fail .    # find unused Nix declarations
nix run nixpkgs#statix -- check .      # lint Nix expressions
nix run nixpkgs#stylua -- --check home/modules/nvim/plugin
```

Install and run the optional Git hooks with `pre-commit install` and `pre-commit run --all-files`.
