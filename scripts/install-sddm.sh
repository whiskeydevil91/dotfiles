#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# install-sddm.sh
# Installs SDDM with the neon login theme from this repo.
# ------------------------------------------------------------

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
THEME_SRC="$SCRIPT_DIR/../sddm/neon"
THEME_DST="/usr/share/sddm/themes/neon"

# ------------------------------------------------------------
# Self-escalate via sudo (prompt only when needed)
# ------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "==> Elevation required for SDDM installation"
  exec sudo "$SCRIPT_DIR/$(basename "$0")" "$@"
fi

echo "======================================"
echo " Installing SDDM (neon theme)"
echo "======================================"

# ------------------------------------------------------------
# Sanity checks
# ------------------------------------------------------------
if ! command -v pacman >/dev/null; then
  echo "ERROR: This script is intended for Arch Linux"
  exit 1
fi

if [[ ! -f "$THEME_SRC/Main.qml" ]]; then
  echo "ERROR: Neon theme not found at $THEME_SRC"
  exit 1
fi

# ------------------------------------------------------------
# Install packages
# ------------------------------------------------------------
echo "==> Installing SDDM and dependencies"
pacman -S --needed --noconfirm \
  sddm \
  xorg-server \
  qt6-declarative \
  ttf-ibm-plex

# ------------------------------------------------------------
# Disable other display managers (best-effort)
# ------------------------------------------------------------
echo "==> Disabling other display managers (if present)"
systemctl disable gdm lightdm greetd ly 2>/dev/null || true

# ------------------------------------------------------------
# Install the neon theme
# ------------------------------------------------------------
echo "==> Installing neon theme to $THEME_DST"
rm -rf "$THEME_DST"
cp -r "$THEME_SRC" "$THEME_DST"

# ------------------------------------------------------------
# Configure SDDM
# ------------------------------------------------------------
echo "==> Setting SDDM theme to: neon"
mkdir -p /etc/sddm.conf.d

cat >/etc/sddm.conf.d/theme.conf <<CONF
[Theme]
Current=neon
CONF

# Older versions of this script ran the greeter under kwin_wayland,
# which is not installed by these dotfiles. Use the default X11 greeter.
rm -f /etc/sddm.conf.d/wayland.conf

# ------------------------------------------------------------
# Enable SDDM
# ------------------------------------------------------------
echo "==> Enabling SDDM service"
systemctl enable sddm

# ------------------------------------------------------------
# Verify installation
# ------------------------------------------------------------
echo
echo "==> Verifying installation..."

if [[ -f "$THEME_DST/Main.qml" ]]; then
  echo "✓ Neon theme installed"
else
  echo "✗ ERROR: Neon theme missing from $THEME_DST"
  exit 1
fi

# The Hyprland package ships its own session file
if [[ -f /usr/share/wayland-sessions/hyprland.desktop ]]; then
  echo "✓ Hyprland session available"
else
  echo "✗ WARNING: Hyprland session not found - install hyprland first!"
fi

echo
echo "======================================"
echo " SDDM installation complete"
echo "======================================"
echo
echo "Preview the theme without logging out:"
echo "  sddm-greeter-qt6 --test-mode --theme $THEME_DST"
echo
