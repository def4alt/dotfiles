# Dotfiles

Declarative configuration for `alderbook`, an Apple silicon Mac managed by
[mise](https://mise.jdx.dev). `config.toml` is the single source of truth: it
declares host packages, macOS preferences, dotfiles, the login shell and the
verification tasks.

Start with [AGENTS.md](AGENTS.md) if you are an agent, and
[docs/HISTORY.md](docs/HISTORY.md) for why the system looks like this.

## Repository layout

```text
.
├── config.toml            # Tools, packages, macOS defaults, dotfiles, tasks
├── mise.lock              # Pinned versions of the [tools] entries
├── AGENTS.md              # Invariants and red lines for agents
├── home/                  # Dotfile sources, symlinked into $HOME
│   ├── bash_profile.sh    # Login shell: sources profile.sh then bashrc.sh
│   ├── bashrc.sh          # Interactive shell, mise activation, aliases
│   ├── profile.sh         # PATH and RIPGREP_CONFIG_PATH for login sessions
│   ├── inputrc            # Readline bindings and options
│   ├── gitconfig          # Git config with SSH signing and delta
│   ├── gitignore          # Global git ignore
│   ├── git/               # allowed_signers for SSH signature verification
│   ├── npmrc              # Global prefix and allow-scripts
│   ├── ssh_config         # SSH hosts, ControlMaster, 1Password agent
│   ├── bat.conf           # bat theme
│   ├── ghostty.conf       # Terminal emulator
│   ├── herdr/config.toml  # Agent multiplexer
│   ├── ripgrep/ripgreprc  # Ripgrep flags (needs RIPGREP_CONFIG_PATH)
│   └── nvim/              # Neovim configuration (kept writable)
├── tasks/bootstrap.sh     # mise's bootstrap task: post-install work
├── libexec/check.sh       # Asserts nothing is silently broken
├── libexec/clean.sh       # Retention for state that only grows
└── docs/HISTORY.md        # Migration notes and retired components
```

Behaviour here is checked against the installed version's own documentation —
`mise <command> --help`, `mise.jdx.dev/llms.txt`, `ghostty +show-config --docs`,
`:help vim.pack` — because these tools change faster than any summary of them.

Source names encode the file's syntax, not its deployed path: the `[dotfiles]`
table below already carries the path, so `bashrc.sh` and `gitconfig` stay
visible to `shellcheck`, `shfmt`, `rg -t` and editors.

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
mise dot add ~/.bashrc          # Save an edit made in place back to home/
mise lock --global --bump       # Refresh pinned tool versions
mise run check                  # Assert nothing is silently broken
mise run clean                  # Show what retention would delete
mise run clean -- --apply       # Actually delete it
```

Inspect an individual section with `mise bootstrap <part> status`, where part is
one of `packages`, `dotfiles`, `macos defaults`, `macos launchd-agents`,
`services`, `user`, `tools` or `repos`.

## Shell

`~/.bashrc`, `~/.bash_profile`, `~/.profile` and `~/.inputrc` are managed as
whole files, so mise's own `[bootstrap.mise_shell_activate]` is intentionally not
used: `mise activate bash` lives in `home/bashrc.sh` instead.

`home/profile.sh` puts `/opt/homebrew/bin`, `~/.local/bin` and the mise shims
directory on `PATH` before anything else runs. The order matters:
`~/.local/bin` holds the `mise` binary itself, so `~/.bashrc` can evaluate
`mise activate bash`, and it also holds `pi`, `roc`, `opencode` and `uv`, which
are installed outside Homebrew. Everything optional is guarded with
`command -v`, so the shell still starts cleanly while packages are being
installed.

`PAGER`, `LESS=-FRX` are exported so agent-driven commands never page or clear
the screen.

Check this independently of your current terminal, because an interactive session
inherits a `PATH` that hides ordering mistakes:

```sh
env -i HOME="$HOME" TERM=xterm PATH=/usr/bin:/bin /opt/homebrew/bin/bash -lic 'command -v mise nvim op'
```

The login shell is `/opt/homebrew/bin/bash`. Homebrew's bash is required because
the configuration uses bash 5 features (`globstar`, `cmdhist`); macOS's bundled
bash 3.2 does not support them.

## Search

ripgrep has **no** default configuration file: without `RIPGREP_CONFIG_PATH` it
reads none at all. `home/profile.sh` and `home/bashrc.sh` export it, pointing at
`home/ripgrep/ripgreprc`, which turns on `--hidden`, `--smart-case`, `--column`
and truncates very long lines. `mise run check` fails if either link in that
chain breaks.

`~/src/AGENTS.md` documents the checkout layout and the recommended globs for
searching only first-party code.

## Terminal

Ghostty runs `bash -lic "herdr"`, so terminal sessions live in the Herdr server
and outlive the terminal that started them; `prefix+q` detaches and running
`herdr` again reattaches. `home/herdr/config.toml` keeps the `ctrl+space` prefix
and pins `terminal.default_shell`/`terminal.shell_mode` so new panes are login
shells of Homebrew's bash instead of whatever `$SHELL` holds.

Herdr reads its configuration when the server starts. After editing
`home/herdr/config.toml`, apply it without stopping panes:

```sh
herdr server reload-config
```

Verify a pane has the full toolchain, not just a bare `PATH`:

```sh
herdr workspace create --cwd "$HOME" --label probe --no-focus
herdr pane run <pane_id> 'command -v mise nvim op'   # ids come from the JSON response
herdr pane read <pane_id> --source visible --lines 5
herdr workspace close <workspace_id>
```

## Secrets

Secrets are not stored in this repository. They live in 1Password and are read on
demand through the `op` CLI, installed by mise from `1password/tap`.

```sh
op signin                 # interactive sign-in per session
eval "$(op signin)"       # or: authenticate the current shell
op plugin init            # enable the 1Password desktop app integration
```

`config.toml` declares only the opaque reference, never the value:

```toml
[env]
OP_OPENCODE_API_KEY = "op://Private/OpenCode/credential"
```

`op read` requires **vault, item and field**, so the shorter
`op://Private/OpenCode` is rejected as "too few '/'".

`home/bashrc.sh` wraps `opencode` and `pi` so each invocation resolves the key
and passes it to that one process only. Nothing sensitive is written to disk or
exported into the environment of unrelated processes, and both wrappers degrade
to running without the key when `op` is unavailable.

To check a reference resolves, without printing the secret:

```sh
op read "op://Private/OpenCode/credential" | wc -c
```

GitHub access is handled separately by the `gh` CLI, so mise can reuse its token
without a second credential to manage:

```toml
[settings.github]
credential_command = 'gh auth token --hostname "$MISE_CREDENTIAL_HOST"'
```

Check which source mise selected with `mise token github`.

## Maintenance

```sh
mise lock --global --bump                            # Re-resolve pinned [tools]
mise bootstrap packages upgrade --manager brew       # Update formulae
mise bootstrap packages upgrade --manager brew-cask  # Update mise-owned casks
mise run clean -- --apply                            # Apply retention
```

The Touch ID rule for `sudo` is declared as `[bootstrap.files."/etc/pam.d/sudo_local"]`,
so preview it with `mise bootstrap files apply --dry-run` instead of editing the
file by hand.

Inside Neovim, run `:lua vim.pack.update()` and confirm with `:write` to update
the pinned plugin revisions in `home/nvim/nvim-pack-lock.json`. Format Lua with
`stylua`, shell code with `shfmt`, YAML with `yamlfmt` and TOML with `taplo`;
`pre-commit install` wires all of that plus `gitleaks` into every commit.

## Agents

`mise mcp` is registered as an MCP server in pi, Claude Code and Codex, so an
agent can read the active toolchain, environment and task list instead of
guessing, and run declared tasks:

```sh
pi mcp add mise -- /Users/def4alt/.local/bin/mise mcp
claude mcp add --scope user mise -- /Users/def4alt/.local/bin/mise mcp
```

The absolute path matters: GUI-launched clients do not inherit the shell `PATH`.
Without `--cd` the server uses the client's working directory. `mise://env`
returns real values, so add `"env": { "MISE_SAFE": "1" }` to the server entry for
projects you have not reviewed; safe mode disables env reads and `run_task`.

Agent-facing state is deliberately out of the repository but covered by the same
verification:

- `AGENTS.md` (this repo) and `~/src/AGENTS.md` carry the invariants.
- Skills live once in `~/.agents/skills`; `~/.pi/agent/skills` and
  `~/.claude/skills` are symlinks into it. `mise run check` fails on a dangling
  link, which is how five silently-lost skills were found.
- `mise run clean` applies retention to `~/.claude/jobs`,
  `~/.claude/projects`, `~/.codex/sessions`, `~/.pi/agent/sessions`,
  `~/src/scratch` and `~/backups`.

See [docs/HISTORY.md](docs/HISTORY.md) for the nix-darwin migration notes and
the list of retired components (tmux, AeroSpace, direnv).
