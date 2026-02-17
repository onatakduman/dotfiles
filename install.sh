#!/bin/bash
set -e

DOTFILES_REPO="https://github.com/onatakduman/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

info() { printf "\033[1;34m[INFO]\033[0m %s\n" "$1"; }
ok()   { printf "\033[1;32m[OK]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$1"; }

# --- OS tespiti ---
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
info "Isletim sistemi: $OS"

# --- git kurulumu ---
install_git() {
    if command -v git &>/dev/null; then
        ok "git zaten kurulu"
        return
    fi

    info "git kuruluyor..."
    case "$OS" in
        debian)  sudo apt update && sudo apt install -y git ;;
        fedora)  sudo dnf install -y git ;;
        arch)    sudo pacman -S --noconfirm git ;;
        macos)   xcode-select --install 2>/dev/null || true ;;
        *)       warn "git otomatik kurulamadi"; exit 1 ;;
    esac
    ok "git kuruldu"
}

# --- curl kurulumu ---
install_curl() {
    if command -v curl &>/dev/null; then
        ok "curl zaten kurulu"
        return
    fi

    info "curl kuruluyor..."
    case "$OS" in
        debian)  sudo apt update && sudo apt install -y curl ;;
        fedora)  sudo dnf install -y curl ;;
        arch)    sudo pacman -S --noconfirm curl ;;
        *)       warn "curl otomatik kurulamadi"; exit 1 ;;
    esac
    ok "curl kuruldu"
}

# --- zsh kurulumu ---
install_zsh() {
    if command -v zsh &>/dev/null; then
        ok "zsh zaten kurulu: $(zsh --version)"
        return
    fi

    info "zsh kuruluyor..."
    case "$OS" in
        debian)  sudo apt update && sudo apt install -y zsh ;;
        fedora)  sudo dnf install -y zsh ;;
        arch)    sudo pacman -S --noconfirm zsh ;;
        macos)   brew install zsh ;;
        *)       warn "zsh otomatik kurulamadi, lutfen manuel kurun"; exit 1 ;;
    esac
    ok "zsh kuruldu"
}

# --- Repo clone ---
clone_dotfiles() {
    if [ -d "$DOTFILES_DIR/.git" ]; then
        info "Dotfiles mevcut, guncelleniyor..."
        git -C "$DOTFILES_DIR" pull --ff-only
        ok "Dotfiles guncellendi"
        return
    fi

    if [ -d "$DOTFILES_DIR" ]; then
        warn "$DOTFILES_DIR mevcut ama git reposu degil, yedekleniyor..."
        mv "$DOTFILES_DIR" "${DOTFILES_DIR}.bak"
    fi

    info "Dotfiles indiriliyor..."
    git clone --depth 1 "$DOTFILES_REPO" "$DOTFILES_DIR"
    ok "Dotfiles indirildi: $DOTFILES_DIR"
}

# --- Oh My Zsh kurulumu ---
install_ohmyzsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        ok "Oh My Zsh zaten kurulu"
        return
    fi

    info "Oh My Zsh kuruluyor..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    ok "Oh My Zsh kuruldu"
}

# --- Eklenti kurulumu ---
install_plugin() {
    local name="$1"
    local repo="$2"
    local dest="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"

    if [ -d "$dest" ]; then
        ok "Plugin zaten kurulu: $name"
        return
    fi

    info "Plugin kuruluyor: $name"
    git clone --depth 1 "$repo" "$dest"
    ok "Plugin kuruldu: $name"
}

# --- Symlink ---
link_file() {
    local src="$1"
    local dst="$2"

    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -f "$dst" ]; then
        warn "$dst mevcut, yedekleniyor -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -sf "$src" "$dst"
    ok "Link: $dst -> $src"
}

# --- Varsayilan shell ---
set_default_shell() {
    local zsh_path
    zsh_path="$(command -v zsh)"

    if [ "$SHELL" = "$zsh_path" ]; then
        ok "Varsayilan shell zaten zsh"
        return
    fi

    info "Varsayilan shell zsh olarak ayarlaniyor..."
    if ! grep -q "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    chsh -s "$zsh_path"
    ok "Varsayilan shell: zsh"
}

# --- Ana kurulum ---
main() {
    echo ""
    echo "========================================="
    echo "  Dotfiles Kurulumu"
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

    echo ""
    echo "========================================="
    ok "Kurulum tamamlandi! Terminali yeniden acin."
    echo "========================================="
    echo ""
    echo "Makineye ozel ayarlar icin ~/.zshrc.local dosyasini olusturun."
    echo ""
}

main
