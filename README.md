# Dotfiles

Declarative configuration for `alderbook`, an Apple silicon Mac managed by
[mise](https://mise.jdx.dev). `config.toml` is the single source of truth: it
declares host packages, macOS preferences, dotfiles, the login shell and the
bootstrap task.

## Repository layout

```text
.
├── config.toml            # Packages, macOS defaults, dotfiles, login shell
├── mise.lock              # Pinned versions of the [tools] entries
├── home/                  # Dotfile sources deployed by [dotfiles]
│   ├── bashrc             # Interactive shell, mise activation, aliases
│   ├── bash_profile       # Login shell, PATH
│   ├── profile            # PATH for launchd and GUI sessions
│   ├── inputrc            # Readline bindings and options
│   ├── git/               # Git config and global ignore, with delta
│   ├── aerospace/         # AeroSpace window manager
│   ├── bat/               # bat theme
│   ├── direnv/            # direnv global configuration
│   ├── ghostty/           # Terminal emulator
│   ├── nvim/              # Neovim configuration (kept writable)
│   ├── ssh/               # SSH client configuration
│   └── tmux/              # tmux server and session configuration
├── tasks/bootstrap        # Idempotent post-install work (default handlers)
├── config/                # Application exports not managed by mise
└── .pre-commit-config.yaml
```

## Bootstrap

Install mise, then adopt this repository as the global mise configuration. The
clone lands in `~/.config/mise` and is used for every subsequent `mise` command:

```sh
curl https://mise.run | sh
mise bootstrap --adopt git@github.com:def4alt/dotfiles.git
```

Preview first if you want to see the plan, including the one `sudo` step that
claims the Homebrew prefix:

```sh
mise bootstrap --dry-run
mise bootstrap
mise bootstrap status
```

`mise bootstrap` needs a single interactive `sudo` prompt the first time: the
Homebrew prefix at `/opt/homebrew` has to be owned by the invoking user before
mise can pour formulae into it. Everything after that point runs unprivileged.

Resolving the third-party taps needs GitHub API access, so authenticate the `gh`
CLI before bootstrapping. `config.toml` then asks `gh` for its token:

```sh
gh auth login
mise token github      # must print a source, not (none)
```

The very first run can predate `gh` being installed by mise itself, so pass a
token directly for that one run and drop it afterwards:

```sh
GITHUB_TOKEN=github_pat_… mise bootstrap
```

On this machine the repository is linked in rather than cloned, so the existing
checkout and its history stay authoritative:

```sh
ln -sfn "$HOME/dotfiles" ~/.config/mise
```

## Daily use

```sh
mise bootstrap                  # Re-converge everything (the old `update`)
mise bootstrap status           # Report drift across every section
mise bootstrap status --missing # Exit non-zero when something is out of sync
mise dot status                 # Dotfiles only
mise dot add ~/.bashrc          # Save an edit made in place back to home/bashrc
mise lock --global --bump       # Refresh pinned tool versions
```

Inspect an individual section with `mise bootstrap <part> status`, where part is
one of `packages`, `dotfiles`, `macos defaults`, `macos launchd-agents`,
`services`, `user`, `tools` or `repos`.

## Shell

`~/.bashrc`, `~/.bash_profile`, `~/.profile` and `~/.inputrc` are managed as
whole files, so mise's own `[bootstrap.mise_shell_activate]` is intentionally not
used: `mise activate bash` lives in `home/bashrc` instead.

`home/bash_profile` puts `/opt/homebrew/bin`, `~/.local/bin` and the mise shims
directory on `PATH` before anything else runs. The order matters:
`~/.local/bin` holds the `mise` binary itself, so `~/.bashrc` can evaluate
`mise activate bash`, and it also holds `pi`, `roc`, `opencode` and `uv`, which
are installed outside Homebrew. Everything optional in `home/bashrc` is guarded
with `command -v`, so the shell still starts cleanly while packages are still
being installed.

Check this independently of your current terminal, because an interactive session
inherits a `PATH` that hides ordering mistakes:

```sh
env -i HOME="$HOME" TERM=xterm PATH=/usr/bin:/bin /opt/homebrew/bin/bash -lic 'command -v mise nvim op roc'
```

The login shell is `/opt/homebrew/bin/bash`. Homebrew's bash is required because
the configuration uses bash 5 features (`globstar`, `cmdhist`); macOS's bundled
bash 3.2 does not support them.

## Terminal and tmux

Ghostty runs `bash -lic "tmux new-session -A -s main"`, so the tmux server is
long-lived and outlives any shell change. tmux resolves `default-shell` once at
server start, so `home/tmux/tmux.conf` sets it explicitly instead of relying on
`$SHELL`. After changing the login shell, restart the server so existing sessions
pick it up:

```sh
tmux show-options -g default-shell   # inspect
tmux kill-server                     # new server re-reads tmux.conf
```

Verify a pane has the full toolchain, not just a bare `PATH`:

```sh
tmux new -d -s probe 'command -v mise nvim op; tmux wait-for probe'
```

## Secrets

Secrets are not stored in this repository. They live in 1Password and are read on
demand through the `op` CLI, which `bootstrap.packages` installs as
`1password/tap/1password-cli`.

Sign in once per session, or set up the desktop app integration so no shell
prompt is needed:

```sh
op signin                 # interactive sign-in
eval "$(op signin)"       # or: authenticate the current shell
op plugin init            # enable the 1Password desktop app integration
```

The key lives in the `OpenCode` item in the `Private` vault, which is a 1Password
**API Credential**, so the value is in its `credential` field. `config.toml`
declares only the opaque reference, never the value:

```toml
[env]
OP_OPENCODE_API_KEY = "op://Private/OpenCode/credential"
```

Note that `op read` requires **vault, item and field**, so the shorter
`op://Private/OpenCode` is rejected as "too few '/'".

`home/bashrc` wraps `opencode` and `pi` so each invocation resolves the key with
`op read` and passes it to that one process only. Nothing sensitive is written to
disk or exported into the environment of unrelated processes, and both wrappers
degrade to running without the key when `op` is unavailable.

To check a reference resolves, without printing the secret:

```sh
op read "op://Private/OpenCode/credential" | wc -c
```

GitHub access is handled separately, by the `gh` CLI rather than 1Password,
because `gh` already holds a token and mise can reuse it without a second
credential to manage:

```toml
[settings.github]
credential_command = 'gh auth token --hostname "$MISE_CREDENTIAL_HOST"'
```

Check which source mise selected with `mise token github`.

## Maintenance

```sh
mise lock --global --bump       # Re-resolve pinned [tools] versions
mise bootstrap packages upgrade --manager brew        # Update formulae
mise bootstrap packages upgrade --manager brew-cask   # Update casks that do not self-update
```

Inside Neovim, run `:lua vim.pack.update()` and confirm with `:write` to update
the pinned plugin revisions in `home/nvim/nvim-pack-lock.json`. Format Lua with
`stylua`, shell code with `shfmt`, YAML with `yamlfmt` and TOML with `taplo`.

Install and run the optional Git hooks with `pre-commit install` and
`pre-commit run --all-files`.

## Notes on the migration from nix-darwin

This repository previously used nix-darwin and Home Manager. A few behaviours do
not carry over and are worth knowing about:

- **Touch ID for `sudo` is not declarative.** The old
  `security.pam.services.sudo_local.touchIdAuth` has no mise equivalent. Enable
  it once in System Settings, or by editing
  `/etc/pam.d/sudo_local`.
- **`dockutil` is not used.** `[bootstrap.macos.dock]` has an `apps` list that
  manages pinned Dock tiles declaratively and preserves the bookmarks macOS adds
  to them, which `dockutil` cannot do. The list is deliberately omitted here
  because the Dock currently pins no applications; add `.app` paths to pin them.
- **App Store apps are not managed.** No `mas:` packages are declared because
  none are installed. Add `brew:mas` and `mas:<id>` entries when needed.
- **Neovim language servers are partially provisioned.** `config.toml` installs
  the servers that Homebrew provides. `home/nvim/plugin/40_plugins.lua` also
  references `cssls`, `html`, `jsonls`, `oxlint`, `oxfmt`, `pyright`, `zls`,
  `gofumpt`, `rustfmt` and `zigfmt`, which Homebrew does not package for macOS.
  Those servers simply do not start until you add them. For `jsonls`, add
  `"npm:vscode-json-languageserver" = "<version>"` under `[tools]`.
- **Third-party taps need GitHub API access.** `aerospace`, `tinycast` and
  `1password-cli` come from taps, and mise resolves taps over the GitHub API.
  The unauthenticated budget is small, and exhausting it makes any command that
  inspects packages fail, so authenticate `gh` and confirm with
  `mise token github` before running `mise bootstrap`.
- **Formulae are not version-pinned.** Homebrew has no lockfile equivalent, so
  `[bootstrap.packages]` tracks the current stable version of each formula the
  way a `Brewfile` does. Only `ruby` is pinned, via `mise.lock`.
- **`config/rectangle/` is not deployed.** It is kept as a reference; add a
  `[dotfiles]` entry pointing at
  `~/Library/Application Support/Rectangle/RectangleConfig.json` to manage it.