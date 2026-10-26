#!/usr/bin/env bash
# Assert the things that fail silently: dead config, renamed sources, missing
# hooks, broken symlinks. Run with `mise run check`; exits non-zero on failure.
set -uo pipefail

repo=$(cd "$(dirname "$0")/.." && pwd)
cd "$repo" || exit 1

fail=0
ok() { printf '  ok    %s\n' "$1"; }
bad() {
  printf '  FAIL  %s\n' "$1"
  fail=$((fail + 1))
}
skip() { printf '  skip  %s\n' "$1"; }

echo "dotfile sources"
sources=$(grep -o 'source = "[^"]*"' config.toml | sed 's/source = "//; s/"$//' | sort -u)
if [ -z "$sources" ]; then
  bad "config.toml has no [dotfiles] sources"
else
  while IFS= read -r src; do
    if [ -e "$src" ]; then
      ok "$src"
    else
      bad "$src is declared but missing"
    fi
  done <<<"$sources"
fi

echo "sources outside [dotfiles]"
undeployed=0
while IFS= read -r name; do
  case $name in
    home/nvim | home/nvim/*) continue ;; # deployed as one directory symlink
  esac
  if [ -d "$name" ]; then
    grep -Fq "source = \"$name/" config.toml && continue
  else
    grep -Fq "source = \"$name\"" config.toml && continue
  fi
  bad "$name exists but is not deployed by [dotfiles]"
  undeployed=$((undeployed + 1))
done < <(find home -mindepth 1 -maxdepth 2)
if [ "$undeployed" = "0" ]; then
  ok "every home/ entry is deployed"
fi

echo "tracked debris"
debris=$(git ls-files | grep -cE '\.(bak|orig|rej|swp)$' || true)
if [ "$debris" = "0" ]; then
  ok "no .bak/.orig/.rej tracked"
else
  bad "$debris tracked backup file(s)"
fi

echo "ripgrep"
if command -v rg >/dev/null; then
  probe=$(mktemp -d)
  : >"$probe/.hidden-probe"
  found=$(cd "$probe" && RIPGREP_CONFIG_PATH="$repo/home/ripgrep/ripgreprc" rg --files 2>/dev/null | grep -c hidden-probe || true)
  rm -rf "$probe"
  if [ "$found" = "1" ]; then
    ok "ripgreprc flags apply"
  else
    bad "ripgreprc is not applied by ripgrep"
  fi
  for f in home/profile.sh home/bashrc.sh; do
    if grep -q RIPGREP_CONFIG_PATH "$f"; then
      ok "$f exports RIPGREP_CONFIG_PATH"
    else
      bad "$f does not export RIPGREP_CONFIG_PATH"
    fi
  done
else
  skip "ripgrep not installed"
fi

echo "shell"
shell_files=$(git ls-files '*.sh')
if command -v shellcheck >/dev/null; then
  # shellcheck disable=SC2086
  if shellcheck -s bash $shell_files >/dev/null; then
    ok "shellcheck clean"
  else
    bad "shellcheck findings (run: shellcheck -s bash $shell_files)"
  fi
else
  skip "shellcheck not installed"
fi
if command -v shfmt >/dev/null; then
  if shfmt -i 2 -ci -d . >/dev/null; then
    ok "shfmt clean"
  else
    bad "shfmt would reformat files"
  fi
else
  skip "shfmt not installed"
fi

echo "hooks"
if [ -x .git/hooks/pre-commit ]; then
  ok "pre-commit hook installed"
else
  bad "pre-commit hook missing (run: pre-commit install)"
fi

echo "skills"
dangling=0
for link in "$HOME"/.pi/agent/skills/*; do
  if [ -L "$link" ] && [ ! -e "$link" ]; then
    dangling=$((dangling + 1))
  fi
done
if [ "$dangling" = "0" ]; then
  ok "no dangling skill links"
else
  bad "$dangling dangling skill link(s) in ~/.pi/agent/skills"
fi

echo "deployed symlinks"
broken=0
while IFS= read -r target; do
  if [ -L "$target" ] && [ ! -e "$target" ]; then
    bad "$target is a broken symlink"
    broken=$((broken + 1))
  fi
done < <(grep -o '^"[^"]*"' config.toml | tr -d '"' | grep '^~/' | sed "s|~|$HOME|")
if [ "$broken" = "0" ]; then
  ok "all deployed symlinks resolve"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "check: all good"
else
  echo "check: $fail problem(s)"
  exit 1
fi
