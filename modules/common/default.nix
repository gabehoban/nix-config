{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    ./documentation.nix
    ./gpg.nix
    ./neovim.nix
    ./nix.nix
    ./pki.nix
    ./secrets.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
