# Created by new user for 5.9

# Starship
eval "$(starship init zsh)"

# Zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /home/josedev/zsh-autocomplete/zsh-autocomplete.plugin.zsh

autoload -Uz compinit
compinit

# zoxide
eval "$(zoxide init zsh)"

# Atuin
. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

# Brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# fnm
FNM_PATH="/home/josedev/.local/share/fnm"
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

# opencode
export PATH=/home/josedev/.opencode/bin:$PATH

# golang-go

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Alias
alias reload='source ~/.zshrc'
alias inst='sudo apt install -y'
alias updist='sudo apt dist-upgrade -y'
alias upgrade='sudo apt update && sudo apt upgrade -y'
alias cleanup='sudo apt autoremove && sudo apt autoclean -y'
alias xzf?'sudo tar -xzf -y'

# function eza
function la() {
  eza --grid --icons -a --long --header --accessed --group-directories-first "$@"
}

function ll() {
  eza --tree --level=1 --long --header --accessed --group-directories-first "$@"
}

function lla() {
  eza --tree --level=1 -a --long --header --accessed --group-directories-first "$@"
}

function lll() {
  eza --tree --level=2 -a --long --header --accessed --group-directories-first "$@"
}

function llll() {
  eza --tree --level=3 -a --long --header --accessed --group-directories-first "$@"
}
