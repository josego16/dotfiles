# =========================================================
# fzf
# =========================================================

export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'  # strip-cwd-prefix removes the leading ./ from results

# Ctrl-T uses fd
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# UI (applies to all fzf modes)
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --style=full
  --border --padding=1,2
  --prompt="> "
  --pointer="▸"
  --marker="▎"
  --scrollbar="▐"
  --preview-window=right:65%:wrap:border-left
  --bind="ctrl-/:toggle-preview"
  --bind="ctrl-y:accept"
  --bind="focus:transform-header:file --brief {} 2>/dev/null || echo \"(no file)\""
  --color="border:#aaaaaa,label:#cccccc"
  --color="preview-border:#9999cc,preview-label:#ccccff"
  --color="list-border:#669966,list-label:#99cc99"
  --color="input-border:#996666,input-label:#ffcccc"
  --color="header-border:#6699cc,header-label:#99ccff"
'

export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'

# Ctrl+T: file picker (with hidden files)
export FZF_CTRL_T_OPTS="
  --preview '$_FZF_PREVIEW_CMD'
  --prompt='Files > '
  --multi
  --bind='ctrl-t:toggle-all'
"

# Ctrl+F: file picker excluding hidden files
_fzf_file_no_hidden() {
  local cmd result
  cmd="${FZF_DEFAULT_COMMAND/--hidden /}"
  result=$(eval "${cmd:-find . -type f}" | fzf --preview "$_FZF_PREVIEW_CMD") \
    && LBUFFER+="$result"
  zle reset-prompt
}
zle -N _fzf_file_no_hidden

export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window=up:3:hidden:wrap
  --prompt='History > '
"

export FZF_ALT_C_COMMAND='fd --type d --hidden --strip-cwd-prefix'
export FZF_ALT_C_OPTS="
  --preview 'eza -lh --icons --git {}'
  --prompt='Dirs > '
"
export FZF_COMPLETION_TRIGGER='**'

zstyle ':fzf-tab:complete:file:*' fzf-preview 'bat --color=always --line-range=:500 $realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -lh --icons --git $realpath'
zstyle ':fzf-tab:complete:*:options' fzf-preview false
