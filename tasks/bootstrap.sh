#!/usr/bin/env bash
# Idempotent setup that mise has no declarative equivalent for.
#
# Run by `mise bootstrap` through the `bootstrap` task phase. Safe to repeat.
# Secrets are not handled here: `home/bashrc` reads them from 1Password on
# demand with `op read`.

set -euo pipefail

# mise's Homebrew manager installs into the prefix but does not manage PATH, so
# the tools this script needs are not necessarily on PATH during bootstrap.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

log() { printf 'bootstrap: %s %s\n' "$1" "$2"; }
warn() { printf 'bootstrap: warning: %s\n' "$1" >&2; }

# --- Default handlers ------------------------------------------------------
# mise manages packages, defaults and dotfiles, but not LaunchServices handler
# bindings, so those need duti.

if ! command -v duti >/dev/null; then
  warn "duti is not installed; skipping default handler setup"
  exit 0
fi

# Ghostty as the system terminal handler.
if duti -s com.mitchellh.ghostty public.terminal >/dev/null 2>&1; then
  log "handler" "com.mitchellh.ghostty -> public.terminal"
else
  warn "failed to set com.mitchellh.ghostty as the public.terminal handler"
fi

# Zed as the editor for source and configuration files.
#
# duti accepts a single extension per invocation, in place of the UTI. Some
# extensions resolve to a dynamic UTI that LaunchServices refuses to reassign
# (error -50), so failures are collected and reported rather than aborting.
zed_extensions=(
  .bash .c .cc .css .go .h .html .ini .java .js .json .jsonc .jsx .lua
  .md .markdown .py .rb .rs .scss .sh .sql .toml .ts .tsx .txt .xml .yaml
  .yml .zig .zsh
)

zed_failed=()
for ext in "${zed_extensions[@]}"; do
  duti -s dev.zed.Zed "$ext" all >/dev/null 2>&1 || zed_failed+=("$ext")
done

log "handler" "dev.zed.Zed -> ${#zed_extensions[@]} extension(s)"
if [ ${#zed_failed[@]} -gt 0 ]; then
  # Either the extension is already handled by Zed and duti has nothing to do,
  # or LaunchServices has no concrete UTI to reassign. Report, do not fail.
  warn "duti could not confirm these extensions: ${zed_failed[*]}"
fi
