# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="ys"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete)

# zsh-autocomplete: varsayılan olarak history eşleştirmesi göster
zstyle ':autocomplete:*' default-context history-incremental-search-backward
zstyle ':autocomplete:*' min-input 1
setopt HIST_FIND_NO_DUPS

source $ZSH/oh-my-zsh.sh

# Ortak PATH
export PATH="$HOME/.local/bin:$PATH"

# Makineye özel ayarlar (bu dosya git'e eklenmez)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
