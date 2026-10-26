# History and migration notes

Why the system looks the way it does. This repository previously used nix-darwin
and Home Manager; the behaviours below did not carry over and are the ones worth
knowing about.

## From nix-darwin to mise

- **Touch ID for `sudo` is outside mise.** The old
  `security.pam.services.sudo_local.touchIdAuth` has no mise equivalent, so
  `/etc/pam.d/sudo_local` is managed by hand:

  ```sh
  cat /etc/pam.d/sudo_local
  # auth       sufficient     pam_tid.so
  ```

  `sufficient` means an unavailable fingerprint prompt falls through to the
  password, so this cannot lock you out.

- **Caps Lock is remapped back inside mise.** The nix-darwin
  `system.keyboard.remapCapsLockToControl` setting is replaced by
  `[bootstrap.macos.launchd.agents.remap-caps-lock]` in `config.toml`: a
  `hidutil` mapping does not survive a reboot, so the LaunchAgent reapplies
  Caps Lock → Control at every login. Inspect the live mapping with
  `hidutil property --get "UserKeyMapping"`.

- **`dockutil` is not used.** `[bootstrap.macos.dock]` has an `apps` list that
  manages pinned Dock tiles declaratively and preserves the bookmarks macOS adds
  to them, which `dockutil` cannot do. The list is deliberately omitted because
  the Dock currently pins no applications; add `.app` paths to pin them.

- **Homebrew is installed but not required.** mise pours formulae itself and
  reads the Cellar directly, so it never shells out to `brew`. The `brew` CLI is
  present for `brew search`, `brew info` and ad-hoc installs, cloned from the
  Homebrew repository at the latest release rather than run through its
  installer, which would have cleared the Cellar and Caskroom.

  `brew doctor` reports one expected class of warning: casks installed by mise
  (`1password-cli`, `font-jetbrains-mono`) have no Homebrew metadata, so brew
  will not upgrade them. That is the point — `mise bootstrap packages upgrade`
  owns them. Do not "fix" it with `brew reinstall --cask --force`, which hands
  ownership to brew and makes mise report "multiple Caskroom versions".

- **App Store apps are not managed.** No `mas:` packages are declared because
  none are installed. Add `brew:mas` and `mas:<id>` entries when needed.

- **Neovim language servers are partially provisioned.** `config.toml` installs
  the servers Homebrew provides. `home/nvim/plugin/40_plugins.lua` also
  references `cssls`, `html`, `jsonls`, `oxlint`, `oxfmt`, `pyright`, `zls`,
  `gofumpt`, `rustfmt` and `zigfmt`, which Homebrew does not package for macOS.
  Those servers simply do not start until you add them. For `jsonls`, add
  `"npm:vscode-json-languageserver" = "<version>"` under `[tools]`.

- **Third-party taps need GitHub API access.** `tinycast` and `1password-cli`
  come from taps, and mise resolves taps over the GitHub API. The unauthenticated
  budget is small, and exhausting it makes any command that inspects packages
  fail, so authenticate `gh` and confirm with `mise token github` before running
  `mise bootstrap`.

- **Formulae are not version-pinned.** Homebrew has no lockfile equivalent, so
  `[bootstrap.packages]` tracks the current stable version of each formula the
  way a `Brewfile` does. Only `ruby` and `gcloud` are pinned, via `[tools]` and
  `mise.lock`.

## Retired components

| Component | Replaced by | Why |
| --- | --- | --- |
| tmux | herdr | Terminal sessions survive the terminal; Herdr keeps the `ctrl+space` prefix |
| AeroSpace | native macOS window management | Removed; keybindings no longer exist |
| direnv | nothing | `.envrc`-based env loading was unused; `mise` covers tool/env per project |
| nix flakes in `~/src` | `mise.toml` per project | `flake.nix`/`flake.lock` files were deleted with the nix removal |
