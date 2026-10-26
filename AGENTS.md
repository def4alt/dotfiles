# dotfiles

- **mise owns formulae and casks.** `brew reinstall --cask --force` hands one
  back to Homebrew and makes `mise bootstrap status` fail; `brew doctor`'s
  missing-metadata warning is expected.
- **`mise bootstrap packages prune` removes every undeclared leaf.** Anything
  installed but absent from `[bootstrap.packages]` disappears.
- **`[bootstrap.*]` does not merge from `conf.d/`.** `[env]`, `[tools]`,
  `[settings]`, `[dotfiles]` and `[tasks]` do; macOS defaults, packages and
  launchd entries silently vanish if moved there.
