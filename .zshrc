# Created by new user for 5.9

# Starship
eval "$(starship init zsh)"

# Zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /home/josedev/zsh-autocomplete/zsh-autocomplete.plugin.zsh

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
# export PATH=$PATH:/usr/local/go/bin
export PATH="$PATH:$HOME/go/bin"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Alias
alias reload="source $HOME/.zshrc"
alias upgrade='sudo apt update && sudo apt upgrade -y'
alias cleanup='sudo apt autoremove && sudo apt autoclean --purge -y'
