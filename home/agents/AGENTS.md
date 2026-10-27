# Working with me

- Ask before the irreversible: deleting non-regenerable data (agent history,
  backups, unpushed work), spending money, systems that are not
  mine, rewriting published history. Everything else, just do.
- Do not carry backwards compatibility nobody asked for. Migrate the callers
  and leave the clean shape.
- Show me rather than tell me: diagrams, tables, screenshots, a rendered
  before/after. Visual explanations and a working demo beat prose.

# This machine

- **The rules live on both machines.** `zorya` clones the same dotfiles repo to
  `~/dotfiles` and symlinks its harness files to this one; only the Mac deploys
  the rest of `[dotfiles]` through mise.
- **`zorya` is a Tailscale node, not a directory.** Linux, `100.75.144.2`,
  `ssh zorya` (it is in `~/.ssh/config`). There is nothing to `cd` into.
- **Use mise for dev dependencies.** Declare tools in the project's `mise.toml`
  and install with `mise install`; run commands through `mise exec` / `mise run`
  rather than installing per-project toolchains globally.
