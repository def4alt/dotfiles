# Managed by mise: https://github.com/def4alt/dotfiles
#
# PATH is set once in ~/.profile, which is sourced below, so that a login shell
# does not prepend the same entries twice.

# shellcheck source=/dev/null
if [[ -f ~/.profile ]]; then
  . ~/.profile
fi

# shellcheck source=/dev/null
if [[ -f ~/.bashrc ]]; then
  . ~/.bashrc
fi

# OrbStack's installer appends this to whichever login file it finds. It is
# kept here deliberately instead, guarded so it is a no-op once OrbStack is
# removed. ~/.orbstack/bin holds docker, docker-compose, kubectl and orb.
# shellcheck source=/dev/null
if [[ -r ~/.orbstack/shell/init.bash ]]; then
  . ~/.orbstack/shell/init.bash
fi
