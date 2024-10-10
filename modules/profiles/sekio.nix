_: {
  imports = [
    # Core Modules
    ../common
    # Network Modules
    ../network
    # NixOS Specific Modules
    ../nixos/boot.nix
    ../nixos/security.nix
    ../nixos/system.nix
    ../nixos/users.nix
    ../nixos/server.nix
    # Services
    ../../services/blocky
    ../../services/endless_ssh
    ../../services/nginx
    ../../services/prometheus
  ];
}
