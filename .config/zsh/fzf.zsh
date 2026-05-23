# =========================================================
# fzf
# =========================================================

export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'  # strip-cwd-prefix removes the leading ./ from results

# Ctrl-T uses fd
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# UI
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt="  "
  --pointer="  "
  --preview-window=right:65%:wrap:border-left
'

export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

# Ctrl+F: file picker excluding hidden files
_fzf_file_no_hidden() {
  local cmd result
  cmd="${FZF_DEFAULT_COMMAND/--hidden /}"
  result=$(eval "${cmd:-find . -type f}" | fzf --preview "$_FZF_PREVIEW_CMD") \
    && LBUFFER+="$result"  # LBUFFER is the text left of the cursor
  zle reset-prompt
}
zle -N _fzf_file_no_hidden

# =========================================================
# fzf-tab (fuzzy completions via fzf)
# =========================================================

# Preview file contents with bat
zstyle ':fzf-tab:complete:*' fzf-preview \
  'bat --color=always --style=plain,numbers --line-range=:500 $realpath'

# Switch group with , and .
zstyle ':fzf-tab:*' switch-group ',' '.'

# Accept ambiguous prefix with Tab instead of expanding
zstyle ':fzf-tab:complete:*' accept-line never

# =========================================================
# navi cheatsheets
# =========================================================

navi-widget() {
  local result
  result=$(navi --print)
  LBUFFER+="$result"
  zle reset-prompt
}
zle -N navi-widget
