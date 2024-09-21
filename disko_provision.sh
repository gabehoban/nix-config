#!/usr/bin/env bash

# Mount over the /nix store for more space
sudo mount /dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_232758800485-part1 /nix

# Copy SSH keys
mkdir ~/.ssh
cp /run/media/nixos/USB/ssh-keys/id_ed25519* ~/.ssh/
chmod 600 ~/.ssh/id_ed25519

# Clone repo
git clone git@github.com:gabehoban/nixos-config

# Install via disko
cd nixos-config

sudo nix run                                           \
    'github:nix-community/disko#disko-install'         \
    --extra-experimental-features "nix-command flakes" \
    --                                                 \
    --flake .#baymax                                   \
    --disk main /dev/disk/by-id/nvme-Samsung_SSD_970_EVO_500GB_S5H7NS1N512889D
