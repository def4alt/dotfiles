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
├── secrets/              # SOPS-encrypted secret documents
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

Secrets under `secrets/` are encrypted with [SOPS](https://getsops.io/) and age and may be committed safely. Each device should use a separate age identity at:

```text
~/.config/sops/age/keys.txt
```

Create an identity and print its public recipient with:

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
```

Only share the resulting `age1…` recipient; never share or commit an `AGE-SECRET-KEY-…` identity. Add a device or recovery recipient to `.sops.yaml`, then rewrap the encrypted file from an already-authorized device:

```sh
sops updatekeys secrets/personal.yaml
```

Store a recovery identity in a password manager or offline, rather than installing it on every device. Edit encrypted files only through SOPS (`sops secrets/personal.yaml`); ordinary formatters can invalidate their MAC, so pre-commit excludes `secrets/*.yaml` from YAML formatting.

## Maintenance

```sh
nix flake update                       # update pinned flake inputs
nix fmt                               # format Nix files
nix flake check --all-systems          # evaluate every host/output
nix run nixpkgs#deadnix -- --fail .    # find unused Nix declarations
nix run nixpkgs#statix -- check .      # lint Nix expressions
nix run nixpkgs#stylua -- --check home/modules/nvim
```

Inside Neovim, run `:lua vim.pack.update()` and confirm with `:write` to update the pinned plugin revisions.

Install and run the optional Git hooks with `pre-commit install` and `pre-commit run --all-files`.
