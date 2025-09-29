#!/usr/bin/env bash

set -e

# --- Colors ---
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# --- Header ---
echo -e "${CYAN}>>> Starting Arch Post-Install Script (Catppuccin Mocha Edition) 🚀${RESET}"
sleep 1

# --- Update system ---
echo -e "${YELLOW}>>> Updating system...${RESET}"
sudo pacman -Syu --noconfirm

# --- Install yay if missing ---
if ! command -v yay &>/dev/null; then
    echo -e "${YELLOW}>>> Installing yay...${RESET}"
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd -
fi

# --- Packages ---
echo -e "${YELLOW}>>> Installing packages...${RESET}"
yay -S --needed --noconfirm \
    neovim python python-pip \
    jdk-openjdk gradle \
    nodejs npm yarn \
    typescript angular-cli \
    hyprland waybar wofi alacritty \
    firefox discord \
    bluez bluez-utils blueman \
    pipewire pipewire-pulse pavucontrol \
    texlive-most texlive-lang \
    zathura zathura-pdf-mupdf \
    mpv viu lf \
    swappy grim slurp \
    starship git stow

# --- Enable Bluetooth ---
echo -e "${YELLOW}>>> Enabling Bluetooth service...${RESET}"
sudo systemctl enable --now bluetooth.service

# --- Apply dotfiles with stow ---
echo -e "${YELLOW}>>> Applying dotfiles with stow...${RESET}"
for dir in */; do
    if [[ "$dir" != ".git/" ]]; then
        stow -R $dir
    fi
done

# --- Install Neovim plugins (headless) ---
echo -e "${YELLOW}>>> Installing Neovim plugins...${RESET}"
nvim --headless "+Lazy! sync" +qa

# --- Install Treesitter parsers ---
echo -e "${YELLOW}>>> Installing Treesitter parsers...${RESET}"
nvim --headless "+TSUpdateSync" +qa

# --- Final Message ---
echo -e "${GREEN}>>> Installation complete! 🎉${RESET}"
echo -e "${CYAN}Reboot now to enjoy Hyprland with Catppuccin Mocha everywhere 🌙${RESET}"

