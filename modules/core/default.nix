{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    ./gpg.nix
    ./nix.nix
    ./pki.nix
    ./secrets.nix
    ./security.nix
    ./system.nix
    ./users.nix
  ];
}
