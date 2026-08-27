# =========================================================
# Defaults
# =========================================================
export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# =========================================================
# Theme
# =========================================================
# Shared with fzf-tab below so both stay in sync
typeset -a _FZF_THEME_COLORS=(
  '--color=fg:#DCD7BA,bg:#1F1F28,hl:#7E9CD8,fg+:#DCD7BA,bg+:#2A2A37'
  '--color=hl+:#7E9CD8,info:#7AA89F,prompt:#E6C384,pointer:#957FB8'
  '--color=marker:#b4a3d0,spinner:#7AA89F,header:#6A9589,border:#54546D'
  '--color=gutter:#2A2A37'
)

export FZF_DEFAULT_OPTS="--style=full --no-separator \
  --border=rounded --info=inline-right \
  --input-border=rounded --list-border=rounded \
  --header-border=rounded --footer-border=rounded --preview-border=rounded \
  ${_FZF_THEME_COLORS[*]}"

# =========================================================
# Previews
# =========================================================
# Internal helper — not exported, nothing outside this file reads it
_FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -50'"

# =========================================================
# Custom pickers
# =========================================================
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
# Completion styles
# =========================================================
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no  # let fzf-tab own the menu
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# =========================================================
# fzf-tab integration
# =========================================================
zstyle ':fzf-tab:*' fzf-flags "${_FZF_THEME_COLORS[@]}" \
  '--border=rounded' \
  '--info=inline-right'

zstyle ':fzf-tab:*' switch-group '<' '>'

zstyle ':fzf-tab:complete:(cd|z|zi):*' fzf-preview \
  'eza --tree --color=always $realpath | head -50'
zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0

# preview the full command for the selected pid
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
  fzf-preview 'echo ${(P)word}'
