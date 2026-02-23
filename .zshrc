# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="ys"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete)

# zsh-autocomplete settings
zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:tab:*' insert-unambiguous yes
zstyle ':autocomplete:tab:*' widget-style menu-select
setopt HIST_FIND_NO_DUPS

source $ZSH/oh-my-zsh.sh

# Tab = normal completion, Ctrl+R = history search
bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete

# Common PATH
export PATH="$HOME/.local/bin:$PATH"

# Machine-specific config (not tracked by git)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
