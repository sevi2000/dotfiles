#!/bin/bash
set -e

# --- CONFIG ---
GPU_DRIVER=${1:-"intel"}   # options: intel | amd | nvidia

echo ">>> Updating system..."
sudo pacman -Syu --noconfirm

echo ">>> Enabling multilib..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
  sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
  sudo pacman -Syu --noconfirm
fi

echo ">>> Installing base packages..."
sudo pacman -S --needed --noconfirm \
  base-devel git \
  wayland xdg-desktop-portal-hyprland \
  polkit elogind seatd dbus

echo ">>> Installing GPU drivers for $GPU_DRIVER..."
case $GPU_DRIVER in
  intel)
    sudo pacman -S --needed --noconfirm mesa libva-intel-driver vulkan-intel
    ;;
  amd)
    sudo pacman -S --needed --noconfirm mesa xf86-video-amdgpu vulkan-radeon
    ;;
  nvidia)
    sudo pacman -S --needed --noconfirm nvidia nvidia-utils nvidia-settings
    ;;
  *)
    echo "Unknown GPU driver option: $GPU_DRIVER"
    exit 1
    ;;
esac

echo ">>> Installing yay (AUR helper)..."
if ! command -v yay &>/dev/null; then
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
fi

echo ">>> Installing Hyprland + environment..."
yay -S --noconfirm hyprland

sudo pacman -S --needed --noconfirm \
  alacritty \
  dunst rofi-wayland waybar \
  wl-clipboard thunar \
  pipewire pipewire-pulse wireplumber pavucontrol \
  networkmanager bluez bluez-utils

echo ">>> Enabling services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth || true

echo ">>> Setting up Hyprland config..."
mkdir -p ~/.config/hypr
if [ ! -f ~/.config/hypr/hyprland.conf ]; then
  cp /usr/share/hyprland/hyprland.conf ~/.config/hypr/
fi

# Replace foot with alacritty in default config (if present)
sed -i 's/foot/alacritty/g' ~/.config/hypr/hyprland.conf || true

echo ">>> Installation complete!"
echo "Reboot your system, login to TTY, and run: Hyprland"
echo "Optional: install a display manager like greetd or SDDM."