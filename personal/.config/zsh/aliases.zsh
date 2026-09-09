# =========================================================
# System
# =========================================================
# Reload shell
alias rl='exec zsh'

# Update aliases file (absolute path so it works from any directory)
alias upalias='$EDITOR "$ZDOTDIR/aliases.zsh"'

# Maintenance
alias apu='sudo apt update && sudo apt upgrade'
alias apuall='sudo apt update && sudo apt full-upgrade'
alias clean='sudo apt autoremove --purge && sudo apt autoclean'

# =========================================================
# Navigation
# =========================================================
# zoxide
if command -v zoxide >/dev/null 2>&1; then
  alias zi='zoxide query -i'
  alias za='zoxide add'
fi

# =========================================================
# File listing
# =========================================================
# Colored ls output
alias ls='ls --color=auto'

# Detailed listing
alias ll='ls -lh'

# Detailed listing including hidden files
alias la='ls -lah'

# Directories only
ld() {
  local -a directories=( *(/N) )
  if (( ${#directories} )); then
    command ls -ld -- $directories
  fi
}

# Sort by size
alias lz='ls -laS'

# =========================================================
# Update Tools
# =========================================================
alias opg='opencode upgrade'
alias ktg='curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin'
