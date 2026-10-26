# AGENTS.md

Instructions for agents working in this repository. It is a machine
configuration, not an application: every change here reaches the live system.

## What this repo is

`~/dotfiles` is mise's global configuration directory, also reachable as
`~/.config/mise` (a symlink). `config.toml` is the single source of truth:
tools, host packages, macOS defaults, dotfiles, login shell, tasks.

Dotfiles are deployed as **symlinks** from `home/` into `$HOME`. Editing
`~/.bashrc` edits `home/bashrc.sh` directly; `git status` sees the change.

## The loop

```sh
mise bootstrap dotfiles apply   # after adding or renaming a source in [dotfiles]
mise bootstrap                  # re-converge everything
mise run check                  # asserts the silent-failure cases (see below)
pre-commit run --all-files      # gitleaks, taplo, shellcheck, shfmt, yamllint
```

`mise bootstrap status` reports drift per section. Exit non-zero on drift with
`mise bootstrap status --missing`.

## Rules that exist because something broke

- **Source names carry syntax, targets carry paths.** `home/bashrc.sh`,
  `home/gitconfig`, `home/ssh_config`. The `[dotfiles]` mapping already encodes
  the deployed path, so a source without an extension only hides the file from
  `shellcheck`, `shfmt`, `rg -t` and editors. Keep the extension.
- **ripgrep reads no config by default.** `RIPGREP_CONFIG_PATH` is exported in
  `home/profile.sh` and `home/bashrc.sh`. Remove either and every flag in
  `home/ripgrep/ripgreprc` is silently ignored. `mise run check` guards this.
- **Never hand a misé-owned cask back to Homebrew.** `brew reinstall --cask
  --force 1password-cli` looks like a fix for a `brew doctor` warning and breaks
  `mise bootstrap status` with "multiple Caskroom versions". Rely on
  `mise bootstrap packages upgrade` instead. The doctor warning is expected.
- **`[bootstrap.*]` does not merge from `conf.d/`.** Tested: `[dotfiles]` and
  `[env]` merge from `~/.config/mise/conf.d/*.toml`, `[bootstrap.macos.*]` does
  not. Keep bootstrap config in `config.toml` or it silently disappears.
- **`mise bootstrap packages prune` removes undeclared leaves.** Declare
  everything installed, even tools you never reference (`ffmpeg`, `mosh`,
  `visual-studio-code` were exactly this trap).
- **Secrets are `op://` references only.** Never write a value. `home/bashrc.sh`
  resolves them per invocation with `op read`.

## Layout

| Path | Purpose |
| --- | --- |
| `config.toml` | Everything declarative (tools, packages, macOS, dotfiles) |
| `home/` | Dotfile sources, symlinked into `$HOME` |
| `tasks/bootstrap.sh` | mise's `bootstrap` task: post-install work |
| `libexec/check.sh`, `libexec/clean.sh` | Drift assertions and retention |
| `docs/HISTORY.md` | Why the system looks like this (nix-darwin migration) |
| `mise.lock` | Pinned versions for `[tools]`; `mise lock --bump` refreshes |

## Red lines

- Do not commit secrets, tokens or `.env` contents.
- Do not edit `~/.config/*` files that are not in `[dotfiles]` and assume they
  survive.
- Do not run `brew upgrade` for casks that mise owns.
- Do not add `github.com/<owner>/<repo>` nesting to `~/src` (see
  `~/src/AGENTS.md`).
