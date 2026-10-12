#!/usr/bin/env bash
set -euo pipefail

################################################################################
#                                                                              #
#                   Neon Hyprland Dotfiles Install Script                     #
#                          by whiskeydevil91                                  #
#                                                                              #
################################################################################
# Run from inside the cloned repo:
#   ./install.sh
#
# Steps:
#   1. Install packages from packages.txt (paru, bootstrapped if missing)
#   2. Back up existing configs, then copy hypr, waybar and kitty to ~/.config
#   3. Install the default wallpaper and .zshrc
#   4. Link ~/hyprdots to this repo (Waybar scripts and update.sh live there)
#   5. Optionally install NVIDIA drivers and the neon SDDM login screen
################################################################################

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

ask() {
    local reply
    read -r -p "$1 [y/N] " reply
    [[ "$reply" =~ ^([yY]|yes|YES)$ ]]
}

# Banner
echo -e "${CYAN}"
cat << "BANNER"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║        🌈  NEON HYPRLAND DOTFILES INSTALLER  🌈          ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

# ------------------------------------------------------------
# Sanity checks
# ------------------------------------------------------------
if [[ ! -f /etc/arch-release ]] || ! command -v pacman &>/dev/null; then
    print_error "This script is designed for Arch Linux."
    exit 1
fi

if [[ $EUID -eq 0 ]]; then
    print_error "Run this script as your normal user, not root. It uses sudo when needed."
    exit 1
fi

# ------------------------------------------------------------
# 1. Packages
# ------------------------------------------------------------
install_paru() {
    if command -v paru &>/dev/null; then
        return
    fi

    print_info "Installing paru (AUR helper)..."
    sudo pacman -S --needed --noconfirm git base-devel

    local build_dir
    build_dir="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "$build_dir/paru"
    (cd "$build_dir/paru" && makepkg -si --noconfirm)
    rm -rf "$build_dir"

    print_success "paru installed"
}

enable_multilib() {
    # Steam and the 32-bit gaming/NVIDIA libraries live in [multilib]
    if grep -q '^\[multilib\]' /etc/pacman.conf; then
        return
    fi

    print_info "Enabling the multilib repository (needed for Steam)..."
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    sudo pacman -Syu --noconfirm
    print_success "multilib enabled"
}

install_packages() {
    print_info "Installing packages from packages.txt..."

    local packages
    mapfile -t packages < <(grep -Ev '^\s*(#|$)' "$REPO_DIR/packages.txt")

    if paru -S --needed --noconfirm "${packages[@]}"; then
        print_success "All packages installed"
        return
    fi

    # One bad package aborts the whole transaction; retry one by one
    print_warning "Bulk install failed, retrying packages one at a time..."
    local failed=()
    for pkg in "${packages[@]}"; do
        paru -S --needed --noconfirm "$pkg" || failed+=("$pkg")
    done

    if [[ ${#failed[@]} -gt 0 ]]; then
        print_warning "These packages could not be installed: ${failed[*]}"
    else
        print_success "All packages installed"
    fi
}

# ------------------------------------------------------------
# 2. Configs
# ------------------------------------------------------------
backup() {
    local path="$1"
    if [[ -e "$path" || -L "$path" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$path" "$BACKUP_DIR/"
        print_info "Backed up $path"
    fi
}

install_configs() {
    print_info "Installing configs..."
    mkdir -p "$HOME/.config"

    for cfg in hypr waybar kitty; do
        backup "$HOME/.config/$cfg"
        cp -r "$REPO_DIR/$cfg" "$HOME/.config/$cfg"
        print_success "$cfg config installed"
    done
    chmod +x "$HOME/.config/hypr/scripts/"*.sh

    backup "$HOME/.zshrc"
    cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"
    print_success "Zsh config installed"
}

# ------------------------------------------------------------
# 3. Wallpaper and user setup
# ------------------------------------------------------------
setup_user() {
    print_info "Setting up home directories and wallpaper..."
    mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Screenshots" "$HOME/.local/bin"

    cp "$REPO_DIR/wallpapers/default.png" "$HOME/Pictures/Wallpapers/default.png"
    print_success "Default wallpaper installed"

    if command -v xdg-user-dirs-update &>/dev/null; then
        xdg-user-dirs-update
    fi

    systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service || true

    # GTK apps read these instead of GTK_THEME on some setups
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "Nordic-Darker" || true
        gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" || true
    fi

    fc-cache -f >/dev/null || true

    # gamemode needs the user in its group to raise game priority
    if getent group gamemode >/dev/null; then
        sudo usermod -aG gamemode "$USER"
    fi
}

# ------------------------------------------------------------
# 4. ~/hyprdots → this repo
# ------------------------------------------------------------
link_repo() {
    local link="$HOME/hyprdots"

    if [[ "$(readlink -f "$link" 2>/dev/null)" == "$REPO_DIR" ]]; then
        return
    fi

    backup "$link"
    ln -s "$REPO_DIR" "$link"
    chmod +x "$REPO_DIR/scripts/"*.sh "$REPO_DIR/scripts/waybar/"*.sh
    print_success "Linked ~/hyprdots to $REPO_DIR"
}

# ------------------------------------------------------------
# 5. Shell
# ------------------------------------------------------------
setup_zsh() {
    local zsh_path
    zsh_path="$(command -v zsh || true)"

    if [[ -n "$zsh_path" && "$SHELL" != "$zsh_path" ]]; then
        print_info "Changing default shell to Zsh..."
        chsh -s "$zsh_path"
        print_success "Default shell changed to Zsh (takes effect on next login)"
    fi
}

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------
main() {
    if ! ask "This will install packages and replace your Hyprland, Waybar, Kitty and Zsh configs. Continue?"; then
        print_error "Installation cancelled."
        exit 1
    fi

    enable_multilib
    install_paru
    install_packages
    install_configs
    setup_user
    link_repo
    setup_zsh

    echo
    if ask "Install NVIDIA drivers?"; then
        "$REPO_DIR/scripts/nvidia.sh"
    fi

    echo
    if ask "Install the neon SDDM login screen?"; then
        "$REPO_DIR/scripts/install-sddm.sh"
    fi

    echo
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                 Installation Complete! 🎉                ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo
    print_info "Next steps:"
    echo "  1. Reboot"
    echo "  2. Select 'Hyprland' on the login screen"
    echo "  3. Press SUPER + / to see every keybinding"
    echo
    if [[ -d "$BACKUP_DIR" ]]; then
        print_warning "Your old configs are backed up in: $BACKUP_DIR"
    fi
}

main
