{
  description = "NixOS and Home Manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hardware.url = "github:nixos/nixos-hardware/master";
    nix-colors.url = "github:misterio77/nix-colors";
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-unstable";
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.1";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      hardware,
      impermanence,
      disko,
      lanzaboote,
      nix-index-database,
      nixos-cosmic,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      overlays = import ./overlays/unstable-pkgs.nix { inherit inputs; };

      environment.systemPackages = [ nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style ];
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

      # NixOS Configs
      nixosConfigurations = {
        # Main Desktop
        "baymax" = nixpkgs.lib.nixosSystem rec {
          specialArgs = {
            inherit inputs outputs;
            vars = {
              username = "gabehoban";
            };
          };
          system = "x86_64-linux";
          modules = [
            ./hosts/baymax/configuration.nix
            home-manager.nixosModules.home-manager
            { home-manager.extraSpecialArgs = specialArgs; }
          ];
        };

        # ADS-B Server
        "skyio" = nixpkgs.lib.nixosSystem rec {
          specialArgs = {
            inherit inputs outputs;
            vars = {
              username = "gabehoban";
            };
          };
          system = "aarch64-linux";
          modules = [
            ./hosts/skyio/configuration.nix
            home-manager.nixosModules.home-manager
            { home-manager.extraSpecialArgs = specialArgs; }
          ];
        };
      };
    };
}
