_: {
  imports = [
    ./hardware-configuration.nix
    ../../disko/baymax.nix
    # Desktop
    ../../modules/shared
    ../../modules/nixos/desktops/gnome.nix
    # Hardware
    ../../modules/nixos/hardware/audio
    ../../modules/nixos/hardware/bluetooth
    ../../modules/nixos/hardware/btrfs-filesystem
    ../../modules/nixos/hardware/nvidia
    ../../modules/nixos/hardware/secureboot
    ../../modules/nixos/hardware/tpm
    ../../modules/nixos/hardware/yubikey
    # System
    ../../modules/nixos/system/boot
    ../../modules/nixos/system/time
    ../../modules/nixos/system/environment
    ../../modules/nixos/system/impermanence
    # Security
    ../../modules/nixos/security
    # Services
    ../../modules/nixos/services
    # User
    ../../modules/nixos/user
  ];

  networking.hostName = "baymax";
  networking.networkmanager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
