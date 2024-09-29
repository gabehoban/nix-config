{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    ./system.nix
    ./users.nix
    ./gpg.nix
    ./openssh.nix
    ./secrets.nix
    ./security.nix
    ./nix.nix
  ];
}
