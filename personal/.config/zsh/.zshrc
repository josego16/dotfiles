# Powerful but minimal zsh configuration
# Author: Jose Maria
# GitHub: https://www.github.com/josego16

# =========================================================
# History
# =========================================================
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# =========================================================
# Shell behaviour
# =========================================================
setopt AUTOCD
setopt NOBEEP
setopt EXTENDED_GLOB
setopt NUMERIC_GLOB_SORT  # sort file10 after file9, not after file1

# =========================================================
# Smart directory navigation
# =========================================================
# Initialize zoxide
eval "$(zoxide init zsh)"

# =========================================================
# Completion
# =========================================================
# Load completion system
autoload -Uz compinit

compinit -u -d "$XDG_CACHE_HOME/zsh/zcompdump"

# Enable interactive completion menu selection
zstyle ':completion:*' menu select

# Make completion case-insensitive
# Example: "doc" can complete to "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # lowercase input matches upper and lower

# =========================================================
# Fuzzy finder
# =========================================================
eval "$(fzf --zsh)"

# =========================================================
# Modular Config Files
# =========================================================
# fzf configuration
source "$ZDOTDIR/fzf.zsh"

# Aliases
source "$ZDOTDIR/aliases.zsh"

# Custom keybindings
source "$ZDOTDIR/bindings.zsh"

# Plugins
source "$ZDOTDIR/plugins.zsh"

# Prompt/theme
source "$ZDOTDIR/prompt.zsh"

# =========================================================
# PATH
# =========================================================
# Prepend only when missing so nested shells (e.g. `rl`) don't stack PATH
_path_prepend() {
  case ":$PATH:" in *":$1:"*) return ;; esac
  export PATH="$1:$PATH"
}

# opencode
_path_prepend "$HOME/.opencode/bin"
