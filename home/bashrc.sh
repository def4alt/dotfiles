# Managed by mise: https://github.com/def4alt/dotfiles
# Commands that should be applied only for interactive shells.
[[ $- == *i* ]] || return

# Login shells get PATH from ~/.profile. A non-login interactive shell (plain
# `bash`, no -l) does not, so fall back to the same entries without duplicating
# them when they are already present.
if ! command -v mise >/dev/null; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
fi

# ~/.profile only reaches login shells, and ripgrep silently reads no config at
# all without this, so repeat the export here for non-login interactive shells.
if [[ -z ${RIPGREP_CONFIG_PATH:-} && -r $HOME/.config/ripgrep/ripgreprc ]]; then
  export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
fi

# Claude Code keeps config and session state in CLAUDE_CONFIG_DIR; without it
# they land as ~/.claude.json and ~/.claude in the home directory.
if [[ -d $HOME/.config/claude ]]; then
  export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
fi

# Put mise-managed tools on PATH. Guarded so a shell without mise still starts.
if command -v mise >/dev/null; then
  eval "$(mise activate bash)"
fi

# Deterministic pager behaviour: agents read command output, so never clear the
# screen on exit (-X) and pass short output straight through (-F).
export LESS="-FRX"
export PAGER=less

if [[ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
  if ! [[ -v BASH_COMPLETION_VERSINFO ]]; then
    # shellcheck source=/dev/null
    . /opt/homebrew/etc/profile.d/bash_completion.sh
  fi
fi

HISTCONTROL=erasedups:ignorespace
HISTFILESIZE=100000
HISTSIZE=10000

shopt -s checkjobs
shopt -s checkwinsize
shopt -s cmdhist
shopt -s extglob
shopt -s globstar
shopt -s histappend

alias -- cat=bat
alias -- ll='ls -lah'
alias -- update='mise bootstrap'

if [[ -n "${GHOSTTY_RESOURCES_DIR}" ]]; then
  builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi

if command -v fzf >/dev/null; then
  eval "$(fzf --bash)"
fi

if command -v oh-my-posh >/dev/null; then
  eval "$(oh-my-posh init bash --config onehalf.minimal)"
fi

if command -v zoxide >/dev/null; then
  eval "$(zoxide init bash --cmd cd)"
fi

# Read API keys from 1Password on demand. Only the opaque references live in the
# environment; the values are resolved per invocation and never exported to
# unrelated processes. Requires an authenticated `op` session.
op_read() {
  if ! command -v op >/dev/null; then
    printf 'warning: 1Password CLI not found; API keys unavailable\n' >&2
    return 1
  fi
  op read "$1" 2>/dev/null
}

opencode() {
  local key
  key="$(op_read "$OP_OPENCODE_API_KEY")"
  if [[ -n $key ]]; then
    OPENCODE_API_KEY="$key" command opencode "$@"
  else
    command opencode "$@"
  fi
}

pi() (
  key="$(op_read "$OP_OPENCODE_API_KEY")"
  if [[ -n $key ]]; then
    export OPENCODE_API_KEY="$key"
  fi

  command pi "$@"
)
