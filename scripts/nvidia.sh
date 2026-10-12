#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " NVIDIA Driver Install (Arch) "
echo "======================================"

# -------------------------------
# Self-escalate via sudo
# -------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "==> Elevation required for NVIDIA installation"
  exec sudo "$0" "$@"
fi

# -------------------------------
# Safety checks
# -------------------------------
if ! command -v pacman >/dev/null; then
  echo "ERROR: This script is for Arch Linux only"
  exit 1
fi

# -------------------------------
# Detect kernel
# -------------------------------
KERNEL="$(uname -r)"

echo "==> Detected kernel: $KERNEL"

INSTALL_PKGS=(
  nvidia
  nvidia-utils
  nvidia-settings
  linux-headers
)

if [[ "$KERNEL" == *"lts"* ]]; then
  echo "==> LTS kernel detected, adding LTS packages"
  INSTALL_PKGS+=(
    nvidia-lts
    linux-lts-headers
  )
fi

# -------------------------------
# System update
# -------------------------------
echo "==> Updating system"
pacman -Syu --noconfirm

# -------------------------------
# Install NVIDIA drivers
# -------------------------------
echo "==> Installing NVIDIA packages"
pacman -S --needed --noconfirm "${INSTALL_PKGS[@]}"

# -------------------------------
# Blacklist nouveau
# -------------------------------
echo "==> Blacklisting nouveau driver"
cat >/etc/modprobe.d/blacklist-nouveau.conf <<EOF
blacklist nouveau
options nouveau modeset=0
EOF

# -------------------------------
# NVIDIA DRM (Wayland support)
# -------------------------------
echo "==> Enabling NVIDIA DRM modeset"
cat >/etc/modprobe.d/nvidia.conf <<EOF
options nvidia_drm modeset=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF

# -------------------------------
# CRITICAL: Add NVIDIA modules to initramfs
# -------------------------------
echo "==> Adding NVIDIA modules to mkinitcpio.conf"

MKINITCPIO_CONF="/etc/mkinitcpio.conf"
BACKUP_CONF="${MKINITCPIO_CONF}.bak.$(date +%Y%m%d-%H%M%S)"

# Backup original config
cp "$MKINITCPIO_CONF" "$BACKUP_CONF"
echo "==> Backup saved to: $BACKUP_CONF"

# Check if MODULES line exists and update it
if grep -q "^MODULES=" "$MKINITCPIO_CONF"; then
  # Check if nvidia modules are already present
  if ! grep "^MODULES=" "$MKINITCPIO_CONF" | grep -q "nvidia"; then
    echo "==> Adding NVIDIA modules to existing MODULES line"

    # Replace MODULES line to include nvidia modules
    # This handles various formats: MODULES=() or MODULES=(other modules)
    sed -i 's/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' "$MKINITCPIO_CONF"

    # Clean up any double spaces
    sed -i 's/MODULES=( /MODULES=(/' "$MKINITCPIO_CONF"
  else
    echo "==> NVIDIA modules already present in mkinitcpio.conf"
  fi
else
  # MODULES line doesn't exist, add it
  echo "==> Creating MODULES line with NVIDIA modules"
  echo "MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" >> "$MKINITCPIO_CONF"
fi

echo "==> Current MODULES configuration:"
grep "^MODULES=" "$MKINITCPIO_CONF"

# -------------------------------
# Regenerate initramfs
# -------------------------------
echo "==> Regenerating initramfs (this may take a moment)"
mkinitcpio -P

# -------------------------------
# Update GRUB (if present)
# -------------------------------
if [[ -f /etc/default/grub ]]; then
  echo "==> Updating GRUB kernel parameters"

  GRUB_PARAMS="nvidia_drm.modeset=1"

  if ! grep -q "$GRUB_PARAMS" /etc/default/grub; then
    sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$GRUB_PARAMS /" /etc/default/grub
    echo "==> GRUB parameters added"
  else
    echo "==> GRUB parameters already present"
  fi

  grub-mkconfig -o /boot/grub/grub.cfg
  echo "==> GRUB configuration updated"
else
  echo "==> GRUB not detected, skipping bootloader config"
  echo "    If using systemd-boot, manually add: nvidia_drm.modeset=1"
fi

# -------------------------------
# Vulkan + 32-bit support (gaming)
# -------------------------------
echo "==> Installing Vulkan + 32-bit NVIDIA support"
pacman -S --needed --noconfirm \
  vulkan-icd-loader \
  lib32-nvidia-utils \
  lib32-vulkan-icd-loader

# -------------------------------
# Hyprland environment variables
# -------------------------------
# Written as a Lua module that hyprland.lua loads when it exists.
echo "==> Writing Hyprland NVIDIA environment variables"

REAL_USER="${SUDO_USER:-$(whoami)}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"

HYPR_ENV_DIR="$REAL_HOME/.config/hypr/config"
HYPR_ENV_FILE="$HYPR_ENV_DIR/nvidia.lua"

mkdir -p "$HYPR_ENV_DIR"

cat >"$HYPR_ENV_FILE" <<'LUA'
-- NVIDIA environment variables (written by scripts/nvidia.sh)
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
LUA

chown -R "$REAL_USER":"$REAL_USER" "$REAL_HOME/.config/hypr"

echo "==> Hyprland environment variables written to:"
echo "    $HYPR_ENV_FILE"

# -------------------------------
# Enable NVIDIA services
# -------------------------------
echo "==> Enabling NVIDIA services"
systemctl enable nvidia-suspend.service || true
systemctl enable nvidia-hibernate.service || true
systemctl enable nvidia-resume.service || true

# -------------------------------
# Verification
# -------------------------------
echo
echo "==> Verifying installation..."

# Check if nvidia module is in mkinitcpio
if grep "^MODULES=" "$MKINITCPIO_CONF" | grep -q "nvidia"; then
  echo "✓ NVIDIA modules added to initramfs"
else
  echo "✗ WARNING: NVIDIA modules not found in initramfs"
fi

# Check if nvidia driver is installed
if pacman -Qi nvidia &>/dev/null; then
  echo "✓ NVIDIA driver installed"
else
  echo "✗ ERROR: NVIDIA driver not installed"
fi

# Check if nouveau is blacklisted
if [[ -f /etc/modprobe.d/blacklist-nouveau.conf ]]; then
  echo "✓ Nouveau driver blacklisted"
else
  echo "✗ WARNING: Nouveau not blacklisted"
fi

# -------------------------------
# Done
# -------------------------------
echo
echo "======================================"
echo " NVIDIA installation complete"
echo "======================================"
echo
echo "REBOOT REQUIRED to load the NVIDIA driver"
