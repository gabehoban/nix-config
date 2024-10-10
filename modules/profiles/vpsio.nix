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
    ../../services/attic
    ../../services/endless_ssh
    ../../services/headscale
    ../../services/nginx
    ../../services/prometheus
  ];
}
