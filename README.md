# 🌈 Neon Hyprland Dotfiles

<div align="center">

![Hyprland](https://img.shields.io/badge/Hyprland-Dynamic?style=for-the-badge&logo=wayland&logoColor=white&color=00ffff)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Waybar](https://img.shields.io/badge/Waybar-Custom-ff00ff?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-00ff00?style=for-the-badge)

*A cyberpunk-inspired Hyprland rice with neon aesthetics and smooth animations*

[Screenshots](#-screenshots) • [Features](#-features) • [Installation](#-installation) • [Keybindings](#%EF%B8%8F-keybindings) • [Customization](#-customization)

</div>

---

## 📸 Screenshots

![Desktop Screenshot](screenshots/desktop.png)
*Main desktop with Waybar and neon theme*

![Workspaces](screenshots/workspaces.png)
*Multiple workspace setup*

![SDDM Login](screenshots/sddm.png)
*Sugar Candy SDDM theme*

---

## ✨ Features

### 🎨 **Neon Aesthetic**
- Cyberpunk-inspired color scheme with glowing borders
- Custom neon pill-style Waybar with gradient effects
- Smooth animations with custom bezier curves
- Semi-transparent windows with blur effects

### 🖥️ **Components**
- **Window Manager**: Hyprland (master layout)
- **Status Bar**: Waybar (custom neon theme)
- **Terminal**: Kitty with truecolor support
- **Shell**: Zsh with Spaceship prompt
- **Display Manager**: SDDM with Sugar Candy theme
- **Font**: IBM Plex Mono

### 🎯 **Workflow Optimized**
- Master layout for focused work
- Smart gaps and borders
- Custom workspace assignments per monitor
- System monitoring (GPU, CPU, Memory, Network)

### 🌟 **Visual Effects**
- Rounded corners (10px radius)
- Active/inactive window transparency
- Drop shadows with custom blur
- Border animations with easing curves
- Neon glow effects on UI elements

---

## 🎨 Color Palette

| Element | Color | Hex Code |
|---------|-------|----------|
| **Cyan** (Primary) | ![#00ffff](https://via.placeholder.com/15/00ffff/00ffff.png) | `#00ffff` |
| **Magenta** (Accent) | ![#ff00ff](https://via.placeholder.com/15/ff00ff/ff00ff.png) | `#ff00ff` |
| **Purple** | ![#9d00ff](https://via.placeholder.com/15/9d00ff/9d00ff.png) | `#9d00ff` |
| **Green** | ![#00ff00](https://via.placeholder.com/15/00ff00/00ff00.png) | `#00ff00` |
| **Orange** | ![#ff6600](https://via.placeholder.com/15/ff6600/ff6600.png) | `#ff6600` |
| **Background** | ![#0a0a14](https://via.placeholder.com/15/0a0a14/0a0a14.png) | `#0a0a14` |

---

## 📦 What's Included

```
dotfiles/
├── hypr/               # Hyprland configuration
│   ├── hyprland.conf   # Main config
│   ├── aesthetics.conf # Visual settings
│   └── environment.conf# Environment variables
├── waybar/             # Waybar configuration
│   ├── config.json     # Bar layout & modules
│   └── style.css       # Neon pill theme
├── kitty/              # Kitty terminal config
│   └── kitty.conf      # Terminal settings
├── zsh/                # Zsh configuration
│   └── .zshrc          # Shell config with Frost theme
├── sddm/               # SDDM theme config
│   └── theme.conf      # Sugar Candy customization
├── scripts/            # Custom scripts
│   └── waybar/         # Waybar module scripts
│       ├── cpu.sh
│       ├── gpu.sh
│       ├── memory.sh
│       └── updates.sh
├── screenshots/        # Rice screenshots
├── install.sh          # Automated installer
└── README.md           # This file
```

---

## 🚀 Installation

### Prerequisites

- **OS**: Arch Linux or Arch-based distribution
- **Display**: Wayland-compatible GPU
- **Space**: ~500MB for packages

### Quick Install

```bash
# Clone the repository
git clone https://github.com/whiskeydevil91/dotfiles.git ~/dotfiles

# Run the automated installer
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

The installer will:
- ✅ Backup your existing configurations
- ✅ Install all required packages (Hyprland, Waybar, etc.)
- ✅ Copy dotfiles to correct locations
- ✅ Configure SDDM with neon theme
- ✅ Set up Zsh with plugins
- ✅ Make scripts executable

### Manual Installation

<details>
<summary>Click to expand manual installation steps</summary>

#### 1. Install Required Packages

```bash
# Core packages
sudo pacman -S hyprland waybar kitty zsh sddm ttf-ibm-plex \
               grim slurp wl-clipboard pavucontrol \
               network-manager-applet polkit-kde-agent \
               qt5-wayland qt6-wayland

# Install yay (AUR helper) if not installed
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# AUR packages
yay -S sddm-sugar-candy-git zsh-theme-powerlevel10k-git
```

#### 2. Install Dotfiles

```bash
# Backup existing configs
mkdir -p ~/.config-backup
cp -r ~/.config/hypr ~/.config-backup/ 2>/dev/null || true
cp -r ~/.config/waybar ~/.config-backup/ 2>/dev/null || true
cp ~/.zshrc ~/.config-backup/ 2>/dev/null || true

# Copy new configs
cp -r ~/dotfiles/hypr ~/.config/
cp -r ~/dotfiles/waybar ~/.config/
cp -r ~/dotfiles/kitty ~/.config/
cp ~/dotfiles/zsh/.zshrc ~/

# Copy scripts
mkdir -p ~/hyprdots/scripts
cp -r ~/dotfiles/scripts/* ~/hyprdots/scripts/
chmod +x ~/hyprdots/scripts/**/*.sh
```

#### 3. Configure SDDM

```bash
# Enable SDDM
sudo systemctl enable sddm

# Configure theme
sudo sddm --example-config > /tmp/sddm.conf
sudo mv /tmp/sddm.conf /etc/sddm.conf
sudo sed -i 's/^Current=.*/Current=sugar-candy/' /etc/sddm.conf

# Copy theme customization
sudo cp ~/dotfiles/sddm/theme.conf /usr/share/sddm/themes/sugar-candy/
```

#### 4. Setup Zsh

```bash
# Change default shell
chsh -s $(which zsh)

# Install plugins
sudo pacman -S zsh-syntax-highlighting zsh-autosuggestions
```

#### 5. Reboot

```bash
sudo reboot
```

</details>

---

## ⌨️ Keybindings

### General

| Keybinding | Action |
|------------|--------|
| `SUPER + Q` | Kill active window |
| `SUPER + M` | Exit Hyprland |
| `SUPER + V` | Toggle floating |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + P` | Toggle pseudo-tiling |

### Applications

| Keybinding | Action |
|------------|--------|
| `SUPER + Return` | Launch terminal (Kitty) |
| `SUPER + E` | File manager |
| `SUPER + R` | Application launcher |

### Window Navigation

| Keybinding | Action |
|------------|--------|
| `SUPER + ←/↓/↑/→` | Move focus |
| `SUPER + H/J/K/L` | Move focus (vim keys) |
| `SUPER + SHIFT + ←/↓/↑/→` | Move window |
| `SUPER + SHIFT + H/J/K/L` | Move window (vim keys) |

### Workspaces

| Keybinding | Action |
|------------|--------|
| `SUPER + 1-9` | Switch to workspace 1-9 |
| `SUPER + SHIFT + 1-9` | Move window to workspace 1-9 |
| `SUPER + Mouse Scroll` | Cycle through workspaces |

### Master Layout

| Keybinding | Action |
|------------|--------|
| `SUPER + I` | Increase master windows |
| `SUPER + D` | Decrease master windows |

### Screenshots

| Keybinding | Action |
|------------|--------|
| `SUPER + SHIFT + S` | Screenshot region |
| `Print` | Screenshot full screen |

---

## 🎨 Customization

### Changing Colors

#### Waybar Colors
Edit `~/.config/waybar/style.css`:

```css
/* Change workspace colors */
#workspaces button.active {
    color: #00ffff;  /* Change this to your preferred color */
}

/* Change clock color */
#clock {
    color: #00ffff;  /* Main clock color */
    border: 3px solid #00ffff;  /* Border color */
}
```

#### Hyprland Border Colors
Edit `~/.config/hypr/aesthetics.conf`:

```conf
general {
    col.active_border = rgba(00ffffff) rgba(ff00ffff) 45deg
    col.inactive_border = rgba(1a1a1acc)
}
```

### Adjusting Transparency

Edit `~/.config/hypr/aesthetics.conf`:

```conf
decoration {
    active_opacity = 0.9    # Active window opacity (0.0-1.0)
    inactive_opacity = 0.8  # Inactive window opacity
}
```

### Changing Wallpaper

```bash
# Add your wallpaper
cp /path/to/wallpaper.png ~/.config/hypr/

# Edit hyprland.conf
exec-once = swaybg -i ~/.config/hypr/wallpaper.png
```

### SDDM Theme Colors

Edit `/usr/share/sddm/themes/sugar-candy/theme.conf`:

```conf
MainColor="#00ffff"      # Primary color
AccentColor="#ff00ff"    # Accent color
BackgroundColor="#0a0a14" # Background
```

---

## 🔧 Troubleshooting

### Waybar Not Showing

```bash
# Reload Waybar
killall waybar && waybar &

# Check for errors
waybar 2>&1 | grep error
```

### Hyprland Won't Start

```bash
# Check logs
cat ~/.cache/hyprland/hyprland.log

# Verify Hyprland installation
hyprctl version
```

### SDDM Theme Not Applied

```bash
# Verify SDDM config
cat /etc/sddm.conf | grep Current

# Should show: Current=sugar-candy

# Restart SDDM
sudo systemctl restart sddm
```

### Custom Scripts Not Working

```bash
# Make scripts executable
chmod +x ~/hyprdots/scripts/**/*.sh

# Check script paths in Waybar config
cat ~/.config/waybar/config.json | grep exec
```

### Monitor Configuration

Edit `~/.config/hypr/hyprland.conf` for your specific monitors:

```conf
# Example multi-monitor setup
monitor=DP-1,2560x1440@144,0x0,1
monitor=DP-2,3440x1440@100,2560x0,1
monitor=HDMI-A-1,1920x1080@60,6000x0,1
```

---

## 📚 Dependencies

### Required Packages

- `hyprland` - Dynamic tiling Wayland compositor
- `waybar` - Highly customizable status bar
- `kitty` - GPU-accelerated terminal emulator
- `zsh` - Z shell
- `sddm` - Display manager
- `ttf-ibm-plex` - IBM Plex font family
- `grim` - Screenshot utility
- `slurp` - Region selection tool
- `wl-clipboard` - Wayland clipboard utilities
- `pavucontrol` - PulseAudio volume control
- `network-manager-applet` - Network management
- `polkit-kde-agent` - Authentication agent
- `qt5-wayland` - Qt5 Wayland support
- `qt6-wayland` - Qt6 Wayland support

### AUR Packages

- `sddm-sugar-candy-git` - SDDM theme
- `zsh-theme-powerlevel10k-git` - Zsh theme (optional)

### Optional Packages

- `hyprpicker` - Color picker
- `hyprshot` - Screenshot tool
- `swaylock-effects` - Screen locker
- `rofi-wayland` - Application launcher
- `dunst` - Notification daemon
- `btop` - System monitor

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 💖 Acknowledgments

- [Hyprland](https://hyprland.org/) - Amazing Wayland compositor
- [Waybar](https://github.com/Alexays/Waybar) - Customizable status bar
- [Sugar Candy](https://github.com/Kangie/sddm-sugar-candy) - Beautiful SDDM theme
- [IBM Plex](https://github.com/IBM/plex) - Excellent monospace font
- The Hyprland community for inspiration

---

## 📧 Contact

**whiskeydevil91** - [@whiskeydevil91](https://github.com/whiskeydevil91)

Project Link: [https://github.com/whiskeydevil91/dotfiles](https://github.com/whiskeydevil91/dotfiles)

---

<div align="center">

### ⭐ If you like this rice, please star the repo! ⭐

Made with 💜 and lots of ☕

</div>
