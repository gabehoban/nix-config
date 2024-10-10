_: {
  imports = [
    # Core Modules
    ../common
    ../common/_1password.nix
    ../common/firefox.nix
    ../common/fonts.nix
    # Network Modules
    ../network
    # NixOS Specific Modules
    ../nixos/bluetooth.nix
    ../nixos/boot.nix
    ../nixos/gaming.nix
    ../nixos/gnome.nix
    ../nixos/impermanence.nix
    ../nixos/lanzaboote.nix
    ../nixos/nvidia.nix
    ../nixos/pipewire.nix
    ../nixos/quiet.nix
    ../nixos/security.nix
    ../nixos/system.nix
    ../nixos/users.nix
    ../nixos/yubikey.nix
    # Services
    ../../services/endless_ssh
  ];
}
