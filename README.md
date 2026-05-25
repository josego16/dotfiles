<p align="center">
  <img src="https://img.shields.io/badge/zsh-%23F15A24.svg?style=for-the-badge&logo=zsh&logoColor=white" alt="Zsh">
  <img src="https://img.shields.io/badge/starship-%23DD0B78.svg?style=for-the-badge&logo=starship&logoColor=white" alt="Starship">
  <img src="https://img.shields.io/badge/fzf-%234D4D4D.svg?style=for-the-badge&logo=gnubash&logoColor=white" alt="fzf">
  <img src="https://img.shields.io/badge/linux-%23FCC624.svg?style=for-the-badge&logo=linux&logoColor=black" alt="Linux">
  <img src="https://img.shields.io/badge/eza-%2300AFF0.svg?style=for-the-badge&logo=files&logoColor=white" alt="eza">
  <img src="https://img.shields.io/badge/ripgrep-%23000000.svg?style=for-the-badge&logo=gnubash&logoColor=white" alt="ripgrep">
</p>

<br>

# dotfiles 🚀

Personal macOS development environment — Zsh, Starship, and essential CLI tools configured for productivity.

---

## 📦 Dependencies

### HomeBrew

```sh
brew install eza bat fd fzf zoxide ripgrep lazygit
```

### Official installation

```sh
# zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
# starship
curl -sS https://starship.rs/install.sh | sh
```

---

## 🔧 Setup

**1. Clone the repo**

```sh
git clone https://github.com/josego16/dotfiles.git
```

**2. Point zsh at the config directory**

Add the following to `/etc/zsh/zshenv`:

```sh
if [[ -z "$XDG_CONFIG_HOME" ]]
then
    export XDG_CONFIG_HOME="$HOME/.config"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
then
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi
```

**3. Set zsh as your default shell**

```sh
chsh -s $(which zsh)
```

**4. Create required directories**

```sh
mkdir -p ~/.local/state/zsh   # history
mkdir -p ~/.cache/zsh         # completion cache
```

**5. Start a new shell**

Plugins are installed automatically on first launch via the built-in plugin manager.

---

## 🔌 Plugins

Managed without a third-party plugin manager. Plugins are cloned into `$ZDOTDIR/plugins/` on first launch.

| Plugin | Purpose |
|--------|---------|
| [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) | Syntax highlighting |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-style inline suggestions |
| [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) | Up/down arrow history filtering |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | FZF-powered tab completions |

To update all plugins:

```sh
zplugin-update
```

---

## ⌨️ Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+R` | Fuzzy history search (fzf) |
| `Ctrl+T` | Fuzzy file search including hidden files (fzf + fd) |
| `Ctrl+F` | Fuzzy file search excluding hidden files (fzf + fd) |
| `Ctrl+→` | Move forward one word |
| `Ctrl+←` | Move backward one word |
| `↑` / `↓` | History search by prefix |
| `Ctrl+\` | Toggle autosuggestions |

---

## 🚀 Starship Config

Included in the repo at [`starship.toml`](./starship.toml) and loaded automatically via `STARSHIP_CONFIG` in `.zshenv`. Requires a [Nerd Font](https://www.nerdfonts.com) in your terminal.
