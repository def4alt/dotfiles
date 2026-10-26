# Working with me

A short overview. Detail lives in `~/dotfiles` (machine configuration, including
`README.md` and its `AGENTS.md`) and `~/src/AGENTS.md` (checkout layout).

## Layout

- Projects live in `~/src/<repo>`, at most three levels deep. `vendor/` is
  upstream and read-only, `work/` holds worktrees, `scratch/` is disposable.
- Machine configuration lives in `~/dotfiles`. Read it before changing system
  behaviour rather than guessing from the current state.

## Working style

- Verify against the installed tool's own documentation (`--help`, `:help`, its
  docs site) instead of memory. These tools change fast.
- Prefer the mechanism that already exists over adding a script or a tool.
- Scratch work goes in `~/src/scratch/<date>-<task>`, never in `~/Documents`.

## Secrets

- 1Password only, referenced as `op://` paths. Never write a secret value to
  disk, to a repo or into a config file.

## Skills

- Installed: `agent-browser`, `content-strategy`, `copywriting`,
  `marketing-psychology`, `herdr`. Do not install or create more without asking.
