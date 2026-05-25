# Created by newuser for 5.9

# Powerful but minimal zsh configuration
# Author: Jose Maria Gomez Liñan
# Github: https://github.com/josego16/dotfiles
#
# Uses:
#   Plugins:      fast-syntax-highlighting, zsh-autosuggestions,
#                 zsh-history-substring-search, fzf-tab
#   Prompt:       starship
#   Navigation:   zoxide, fzf, fd
#   CLI tools:    eza, bat, nano, ripgrep, lf
#   Node:         pnpm, fnm (node manager)

# =========================================================
# History
# =========================================================

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# =========================================================
# Shell behaviour
# =========================================================

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT  # sort file10 after file9, not after file1

# =========================================================
# Smart directory navigation & lf
# =========================================================

LF_ICONS=$(cat ~/.config/lf/icons | tr '\n' ':')
export LF_ICONS

# Initialize zoxide
eval "$(zoxide init zsh)"

# =========================================================
# Completion
# =========================================================

# Load completion system
autoload -Uz compinit

# Initialize completion with cached metadata file
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# Enable interactive completion menu selection
zstyle ':completion:*' menu select

# Make completion case-insensitive
# Example: "doc" can complete to "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # lowercase input matches upper and lower

# =========================================================
# Fuzzy finder
# =========================================================

# Homebrew
local fzf_base="/home/linuxbrew/.linuxbrew/opt/fzf"
if [[ -f "$fzf_base/shell/key-bindings.zsh" ]]; then
  source "$fzf_base/shell/key-bindings.zsh"
  source "$fzf_base/shell/completion.zsh"
fi

# =========================================================
# Modular Config Files
# =========================================================

# fzf configuration
source "$ZDOTDIR/fzf.zsh"

# Aliases
source "$ZDOTDIR/aliases.zsh"

# Custom keybindings
source "$ZDOTDIR/bindings.zsh"

# Plugins and plugin manager
source "$ZDOTDIR/plugins.zsh"

# Prompt/theme
source "$ZDOTDIR/prompt.zsh"

# =========================================================
# Development
# =========================================================

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# cargo
export PATH="$HOME/.cargo/bin:$PATH"

# go
export PATH=$PATH:/usr/local/go/bin

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

# pnpm
export PNPM_HOME="/home/josedev/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

#bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun completions
[ -s "/home/josedev/.bun/_bun" ] && source "/home/josedev/.bun/_bun"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export PATH=$PATH:/usr/local/go/bin
