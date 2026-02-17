# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="ys"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete)

# zsh-autocomplete: default to history matching
zstyle ':autocomplete:*' default-context history-incremental-search-backward
zstyle ':autocomplete:*' min-input 1
setopt HIST_FIND_NO_DUPS

source $ZSH/oh-my-zsh.sh

# Common PATH
export PATH="$HOME/.local/bin:$PATH"

# Machine-specific config (not tracked by git)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
