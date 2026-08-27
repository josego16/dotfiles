# =========================================================
# Keybindings
# =========================================================
# NOTE: this file is sourced AFTER plugins.zsh on purpose — the widgets
# referenced here only exist once their plugins have loaded.

# Up/Down -> history substring search (^[[A/^[[B are the arrow escape codes)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Ctrl+Right / Ctrl+Left -> move forward/backward one word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Ctrl+\ -> toggle autosuggestions (useful for screen recordings)
bindkey '^\' autosuggest-toggle

# Ctrl+F -> fuzzy file picker excluding hidden files (widget from fzf.zsh)
bindkey '^F' _fzf_file_no_hidden
