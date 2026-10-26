# dotfiles

Machine configuration. The loop, then the traps.

## Loop

1. Edit the source under `home/`; it is already the live file through a symlink.
2. `mise bootstrap dotfiles apply` after adding or renaming a source.
3. `mise bootstrap` to converge, `mise bootstrap status` to see drift.
4. `pre-commit run --all-files` before committing: gitleaks, taplo, shellcheck,
   shfmt, yamllint.

## Traps

- **mise owns formulae and casks.** Do not `brew reinstall --cask --force` a
  mise-owned cask; `brew doctor`'s missing-metadata warning is expected.
- **`mise bootstrap packages prune` removes undeclared leaves.** Declare
  everything installed in `[bootstrap.packages]`.
- **`[bootstrap.*]` does not merge from `conf.d/`.** Only `[env]`, `[tools]`,
  `[settings]`, `[dotfiles]` and `[tasks]` do.
- **ripgrep reads no config** unless `RIPGREP_CONFIG_PATH` is set: `profile.sh`,
  `bashrc.sh` and `[env]` all export it. Losing all three disables every flag.
- **Dotfile source names carry syntax**, the `[dotfiles]` mapping carries the
  deployed path. `bashrc.sh`, not `bashrc`.
- **macOS system files** are declared in `[bootstrap.files]` (for example
  `/etc/pam.d/sudo_local`). Never edit them by hand.
