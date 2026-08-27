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
alias clean='sudo apt autoremove --purge -y && sudo apt autoclean'

# =========================================================
# Navigation
# =========================================================
# zoxide
alias zi='zoxide query -i'
alias za='zoxide add'

# =========================================================
# File listing
# =========================================================

# Better ls
alias ls='eza --icons'

# Detailed listing
alias ll='eza -lh --icons --git'

# Detailed listing including hidden files
alias la='eza -lah --icons --git'

# Tree view
alias tree='eza --tree --icons'

# Tree limited to 2 levels
alias lt='eza --tree --level=2 --icons'

# Directories only
alias ld='eza -lD --icons'

# Sort by size
alias lz='eza -la --total-size --icons'

# Better cat
alias cat='bat'

# Plain output (no line numbers, ideal for pipes)
alias catp='bat --plain'

# Always print, never page
alias catl='bat --paging=never'

# =========================================================
# Update Tools
# =========================================================
alias opg='opencode upgrade'
alias ktg='curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin'
