{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    ./apparmor.nix
    ./auditd.nix
    ./boot.nix
    ./documentation.nix
    ./gpg.nix
    ./neovim.nix
    ./nix.nix
    ./pki.nix
    ./secrets.nix
    ./security.nix
    ./system.nix
    ./users.nix
  ];
}
