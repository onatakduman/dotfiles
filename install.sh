#!/bin/bash
set -e

DOTFILES_REPO="https://github.com/onatakduman/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

info() { printf "\033[1;34m[INFO]\033[0m %s\n" "$1"; }
ok()   { printf "\033[1;32m[OK]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$1"; }

# --- OS detection ---
detect_os() {
    case "$(uname -s)" in
        Linux*)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                case "$ID" in
                    ubuntu|debian|pop|linuxmint) echo "debian" ;;
                    fedora|rhel|centos|rocky|alma) echo "fedora" ;;
                    arch|manjaro|endeavouros) echo "arch" ;;
                    *) echo "linux-unknown" ;;
                esac
            else
                echo "linux-unknown"
            fi
            ;;
        Darwin*) echo "macos" ;;
        *)       echo "unknown" ;;
    esac
}

OS=$(detect_os)
info "Operating system: $OS"

# --- Install git ---
install_git() {
    if command -v git &>/dev/null; then
        ok "git already installed"
        return
    fi

    info "Installing git..."
    case "$OS" in
        debian)  sudo apt update && sudo apt install -y git ;;
        fedora)  sudo dnf install -y git ;;
        arch)    sudo pacman -S --noconfirm git ;;
        macos)   xcode-select --install 2>/dev/null || true ;;
        *)       warn "Could not install git automatically"; exit 1 ;;
    esac
    ok "git installed"
}

# --- Install curl ---
install_curl() {
    if command -v curl &>/dev/null; then
        ok "curl already installed"
        return
    fi

    info "Installing curl..."
    case "$OS" in
        debian)  sudo apt update && sudo apt install -y curl ;;
        fedora)  sudo dnf install -y curl ;;
        arch)    sudo pacman -S --noconfirm curl ;;
        *)       warn "Could not install curl automatically"; exit 1 ;;
    esac
    ok "curl installed"
}

# --- Install zsh ---
install_zsh() {
    if command -v zsh &>/dev/null; then
        ok "zsh already installed: $(zsh --version)"
        return
    fi

    info "Installing zsh..."
    case "$OS" in
        debian)  sudo apt update && sudo apt install -y zsh ;;
        fedora)  sudo dnf install -y zsh ;;
        arch)    sudo pacman -S --noconfirm zsh ;;
        macos)   brew install zsh ;;
        *)       warn "Could not install zsh automatically, please install manually"; exit 1 ;;
    esac
    ok "zsh installed"
}

# --- Clone repo ---
clone_dotfiles() {
    if [ -d "$DOTFILES_DIR/.git" ]; then
        info "Dotfiles exist, updating..."
        git -C "$DOTFILES_DIR" pull --ff-only
        ok "Dotfiles updated"
        return
    fi

    if [ -d "$DOTFILES_DIR" ]; then
        warn "$DOTFILES_DIR exists but is not a git repo, backing up..."
        mv "$DOTFILES_DIR" "${DOTFILES_DIR}.bak"
    fi

    info "Downloading dotfiles..."
    git clone --depth 1 "$DOTFILES_REPO" "$DOTFILES_DIR"
    ok "Dotfiles downloaded: $DOTFILES_DIR"
}

# --- Install Oh My Zsh ---
install_ohmyzsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        ok "Oh My Zsh already installed"
        return
    fi

    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc || true
    ok "Oh My Zsh installed"
}

# --- Install plugin ---
install_plugin() {
    local name="$1"
    local repo="$2"
    local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"

    if [ -d "$dest" ]; then
        ok "Plugin already installed: $name"
        return
    fi

    info "Installing plugin: $name"
    git clone --depth 1 "$repo" "$dest"
    ok "Plugin installed: $name"
}

# --- Symlink ---
link_file() {
    local src="$1"
    local dst="$2"

    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -f "$dst" ]; then
        warn "$dst exists, backing up -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -sf "$src" "$dst"
    ok "Linked: $dst -> $src"
}

# --- Default shell ---
set_default_shell() {
    local zsh_path
    zsh_path="$(command -v zsh)"

    if [ "$SHELL" = "$zsh_path" ]; then
        ok "Default shell is already zsh"
        return
    fi

    info "Setting default shell to zsh..."
    if ! grep -q "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    sudo chsh -s "$zsh_path" "$USER"
    ok "Default shell: zsh"
}

# --- Root setup ---
setup_root() {
    local zsh_path
    zsh_path="$(command -v zsh)"

    # macOS doesn't typically use root interactively
    if [ "$OS" = "macos" ]; then
        return
    fi

    info "Setting up root user..."

    # Oh My Zsh for root
    if sudo test -d /root/.oh-my-zsh; then
        ok "Root: Oh My Zsh already installed"
    else
        info "Root: Installing Oh My Zsh..."
        sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc || true
        ok "Root: Oh My Zsh installed"
    fi

    # Plugins for root
    local root_custom="/root/.oh-my-zsh/custom/plugins"
    for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete; do
        if sudo test -d "$root_custom/$plugin"; then
            ok "Root: Plugin already installed: $plugin"
        else
            info "Root: Installing plugin: $plugin"
            sudo git clone --depth 1 "https://github.com/$( [ "$plugin" = "zsh-autocomplete" ] && echo "marlonrichert" || echo "zsh-users" )/$plugin.git" "$root_custom/$plugin"
            ok "Root: Plugin installed: $plugin"
        fi
    done

    # Symlink .zshrc for root
    if sudo test -L /root/.zshrc; then
        sudo rm /root/.zshrc
    elif sudo test -f /root/.zshrc; then
        warn "Root: .zshrc exists, backing up -> /root/.zshrc.bak"
        sudo mv /root/.zshrc /root/.zshrc.bak
    fi
    sudo ln -sf "$DOTFILES_DIR/.zshrc" /root/.zshrc
    ok "Root: Linked /root/.zshrc -> $DOTFILES_DIR/.zshrc"

    # Default shell for root
    sudo chsh -s "$zsh_path" root
    ok "Root: Default shell set to zsh"
}

# --- Main ---
main() {
    echo ""
    echo "========================================="
    echo "  Dotfiles Setup"
    echo "========================================="
    echo ""

    install_git
    install_curl
    install_zsh
    clone_dotfiles
    install_ohmyzsh

    install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
    install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    install_plugin "zsh-autocomplete" "https://github.com/marlonrichert/zsh-autocomplete.git"

    link_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

    set_default_shell
    setup_root

    echo ""
    echo "========================================="
    ok "Setup complete! Restart your terminal."
    echo "========================================="
    echo ""
    echo "For machine-specific config, create ~/.zshrc.local"
    echo ""
}

main
