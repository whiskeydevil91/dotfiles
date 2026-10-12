#!/bin/bash

################################################################################
#                                                                              #
#                   Neon Hyprland Dotfiles Install Script                     #
#                          by whiskeydevil91                                  #
#                                                                              #
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Banner
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║        🌈  NEON HYPRLAND DOTFILES INSTALLER  🌈          ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if running on Arch-based system
if ! command -v pacman &> /dev/null; then
    print_error "This script is designed for Arch Linux and derivatives."
    exit 1
fi

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    print_warning "yay AUR helper not found. Installing..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    print_success "yay installed!"
fi

# Backup existing configs
backup_configs() {
    print_info "Backing up existing configurations..."
    
    BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    [ -d "$HOME/.config/hypr" ] && cp -r "$HOME/.config/hypr" "$BACKUP_DIR/"
    [ -d "$HOME/.config/waybar" ] && cp -r "$HOME/.config/waybar" "$BACKUP_DIR/"
    [ -d "$HOME/.config/kitty" ] && cp -r "$HOME/.config/kitty" "$BACKUP_DIR/"
    [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
    
    print_success "Backup created at: $BACKUP_DIR"
}

# Install packages
install_packages() {
    print_info "Installing required packages..."
    
    # Core packages
    PACKAGES=(
        hyprland
        waybar
        kitty
        zsh
        sddm
        ttf-ibm-plex
        git
        grim              # Screenshots
        slurp             # Region select
        wl-clipboard      # Clipboard
        swaybg            # Wallpaper
        pavucontrol       # Audio control
        network-manager-applet  # Network
        polkit-kde-agent  # Authentication
        qt5-wayland
        qt6-wayland
    )
    
    # AUR packages
    AUR_PACKAGES=(
        sddm-sugar-candy-git
        zsh-theme-powerlevel10k-git
    )
    
    print_info "Installing core packages..."
    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
    
    print_info "Installing AUR packages..."
    yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
    
    print_success "All packages installed!"
}

# Install dotfiles
install_dotfiles() {
    print_info "Installing dotfiles..."
    
    DOTFILES_DIR="$HOME/dotfiles"
    
    # Create config directories
    mkdir -p "$HOME/.config/hypr"
    mkdir -p "$HOME/.config/waybar"
    mkdir -p "$HOME/.config/kitty"
    
    # Copy Hyprland config
    if [ -d "$DOTFILES_DIR/hypr" ]; then
        cp -r "$DOTFILES_DIR/hypr/"* "$HOME/.config/hypr/"
        print_success "Hyprland config installed"
    else
        print_warning "Hyprland config not found in dotfiles"
    fi
    
    # Install default wallpaper
    if [ -f "$DOTFILES_DIR/wallpapers/default.png" ]; then
        mkdir -p "$HOME/Pictures/Wallpapers"
        cp "$DOTFILES_DIR/wallpapers/default.png" "$HOME/Pictures/Wallpapers/default.png"
        print_success "Default wallpaper installed"
    else
        print_warning "Default wallpaper not found in dotfiles"
    fi
    
    # Copy Waybar config
    if [ -d "$DOTFILES_DIR/waybar" ]; then
        cp -r "$DOTFILES_DIR/waybar/"* "$HOME/.config/waybar/"
        print_success "Waybar config installed"
    else
        print_warning "Waybar config not found in dotfiles"
    fi
    
    # Copy Kitty config
    if [ -d "$DOTFILES_DIR/kitty" ]; then
        cp -r "$DOTFILES_DIR/kitty/"* "$HOME/.config/kitty/"
        print_success "Kitty config installed"
    else
        print_warning "Kitty config not found in dotfiles"
    fi
    
    # Copy zsh config
    if [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
        cp "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
        print_success "Zsh config installed"
    else
        print_warning "Zsh config not found in dotfiles"
    fi
    
    # Copy scripts
    if [ -d "$DOTFILES_DIR/scripts" ]; then
        mkdir -p "$HOME/hyprdots/scripts"
        cp -r "$DOTFILES_DIR/scripts/"* "$HOME/hyprdots/scripts/"
        chmod +x "$HOME/hyprdots/scripts/"**/*.sh 2>/dev/null || true
        print_success "Scripts installed"
    fi
}

# Install SDDM theme
install_sddm() {
    print_info "Configuring SDDM..."
    
    # Enable SDDM
    sudo systemctl enable sddm
    
    # Create/update SDDM config
    if [ ! -f /etc/sddm.conf ]; then
        print_info "Generating SDDM config..."
        sudo sh -c 'sddm --example-config > /etc/sddm.conf'
    fi
    
    # Set Sugar Candy theme
    sudo sed -i 's/^Current=.*/Current=sugar-candy/' /etc/sddm.conf
    
    # Copy theme config if exists
    if [ -f "$HOME/dotfiles/sddm/theme.conf" ]; then
        sudo cp "$HOME/dotfiles/sddm/theme.conf" /usr/share/sddm/themes/sugar-candy/theme.conf
        print_success "SDDM theme configured"
    else
        print_warning "SDDM theme.conf not found, using defaults"
    fi
}

# Setup Zsh
setup_zsh() {
    print_info "Setting up Zsh..."
    
    # Change default shell to zsh
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_info "Changing default shell to Zsh..."
        chsh -s $(which zsh)
        print_success "Default shell changed to Zsh (will take effect on next login)"
    fi
    
    # Install zsh plugins
    print_info "Installing Zsh plugins..."
    
    # Syntax highlighting
    if [ ! -d /usr/share/zsh/plugins/zsh-syntax-highlighting ]; then
        sudo pacman -S --needed --noconfirm zsh-syntax-highlighting
    fi
    
    # Autosuggestions
    if [ ! -d /usr/share/zsh/plugins/zsh-autosuggestions ]; then
        sudo pacman -S --needed --noconfirm zsh-autosuggestions
    fi
    
    print_success "Zsh configured"
}

# Post-install message
post_install() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                 Installation Complete! 🎉                ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    print_info "Next steps:"
    echo "  1. Log out and log back in (or reboot)"
    echo "  2. Select 'Hyprland' from your login screen"
    echo "  3. Enjoy your neon setup! 🌈"
    echo ""
    print_warning "Notes:"
    echo "  • Your old configs are backed up in: $BACKUP_DIR"
    echo "  • Zsh is now your default shell (takes effect on next login)"
    echo "  • SDDM is enabled and will start on boot"
    echo ""
    print_info "Troubleshooting:"
    echo "  • If Waybar doesn't show: killall waybar && waybar &"
    echo "  • Check Hyprland logs: ~/.cache/hyprland/hyprland.log"
    echo ""
}

# Main installation flow
main() {
    print_info "Starting installation..."
    echo ""
    
    # Ask for confirmation
    read -p "This will install packages and replace configs. Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled."
        exit 1
    fi
    
    backup_configs
    install_packages
    install_dotfiles
    install_sddm
    setup_zsh
    post_install
}

# Run main function
main
