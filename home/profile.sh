# Managed by mise: https://github.com/def4alt/dotfiles
#
# Single owner of PATH for login sessions. ~/.bash_profile sources this file
# rather than repeating it, so entries are not prepended twice.
#
# Order matters:
#   /opt/homebrew/bin  tools installed by mise's Homebrew manager
#   ~/.local/bin       the mise binary itself, plus roc/opencode/uv
#   mise shims         fallback for tools mise manages directly
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

# ripgrep has no default config file: without this variable it reads none at
# all, and every flag in home/ripgrep/ripgreprc (--hidden, --smart-case, the
# --glob excludes) is silently ignored. Guarded so a machine that has not been
# bootstrapped yet, and therefore has no rc file, still starts cleanly.
if [[ -r $HOME/.config/ripgrep/ripgreprc ]]; then
  export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
fi

# Claude Code keeps config and session state in CLAUDE_CONFIG_DIR; without it
# they land as ~/.claude.json and ~/.claude in the home directory.
if [[ -d $HOME/.config/claude ]]; then
  export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
fi
