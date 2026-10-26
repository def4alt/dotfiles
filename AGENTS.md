# dotfiles

Behaviour here that costs time to rediscover. Everything procedural is in
`README.md`.

- **mise owns formulae and casks.** `brew reinstall --cask --force` hands one
  back to Homebrew and makes `mise bootstrap status` fail with duplicate
  Caskroom versions. `brew doctor`'s missing-metadata warning is expected.
- **`mise bootstrap packages prune` removes every undeclared leaf.** Anything
  installed but absent from `[bootstrap.packages]` disappears.
- **`[bootstrap.*]` does not merge from `conf.d/`.** `[env]`, `[tools]`,
  `[settings]`, `[dotfiles]` and `[tasks]` do; macOS defaults, packages and
  launchd entries silently vanish if moved there.
- **ripgrep reads no config file unless `RIPGREP_CONFIG_PATH` is set.** Three
  places export it; lose all three and every flag in `ripgreprc` is ignored
  without a warning.
- **`/etc/pam.d/sudo_local` is managed by `[bootstrap.files]`**, not by hand.
