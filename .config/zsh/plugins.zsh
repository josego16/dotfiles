# =========================================================
# Plugins & Manager
# =========================================================

ZPLUGINDIR="${ZDOTDIR:-$HOME/.config/zsh}/plugins"

_zplugin_load() {
  local plugin_path="${ZPLUGINDIR}/${2}"
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "Installing ${2}..."
    git clone --depth=1 "https://github.com/${1}/${2}" "$plugin_path" \
      || { echo "ERROR: failed to install ${2}" >&2; return 1; }
  fi
  source "${plugin_path}/${2}.plugin.zsh"
}

zplugin-update() {
  local dir
  for dir in "${ZPLUGINDIR}"/*/; do
    echo "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only
  done
}

# ── Load order is critical ──────────────────────────────
#   1. zsh-completions          fpath (compinit already ran)
#   2. aloxaf/fzf-tab           hooks completions → fzf
#   3. zsh-autosuggestions      inline suggestions
#   4. fast-syntax-highlighting syntax highlighting
#   5. zsh-history-substring-search  arrow-key history
# ────────────────────────────────────────────────────────

_zplugin_load zsh-users zsh-completions
_zplugin_load aloxaf fzf-tab
_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zdharma-continuum fast-syntax-highlighting
_zplugin_load zsh-users zsh-history-substring-search
