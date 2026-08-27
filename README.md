# dotfiles

Personal configuration files for Zsh, Kitty, Zed, Git, and OpenCode.

## Structure

```text
.
├── dev/
│   ├── .config/
│   │   ├── kitty/
│   │   ├── zed/
│   │   └── zsh/
│   └── .gitconfig
├── personal/
│   └── .config/
│       ├── kitty/
│       └── zsh/
└── scripts/
```

- `dev/`: development profile with Zsh, Kitty, Zed, and Git.
- `personal/`: personal profile with Zsh and Kitty.
- `scripts/`: standalone setup utilities.

## Setup

**1. Clone the repo**

```sh
git clone https://github.com/josego16/dotfiles ~/.dotfiles
ln -sfn ~/.dotfiles/dev/.config/zsh ~/.config/zsh
```

Use `personal` instead of `dev` for the personal profile.

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
chsh -s "$(which zsh)"
```

**4. Create required directories**

```sh
mkdir -p ~/.local/state/zsh   # history
mkdir -p ~/.cache/zsh         # completion cache
```
