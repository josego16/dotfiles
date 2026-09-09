# =========================================================
# Keybindings
# =========================================================
# Up/Down -> history substring search (^[[A/^[[B are the arrow escape codes)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Ctrl+Right / Ctrl+Left -> move forward/backward one word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Ctrl+\ -> toggle autosuggestions (useful for screen recordings)
bindkey '^\' autosuggest-toggle
