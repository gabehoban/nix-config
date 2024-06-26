{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url  = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Formatter
    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    # Need to Reboot
    nixos-needtoreboot.url = github:thefossguy/nixos-needsreboot;
    nixos-needtoreboot.inputs.nixpkgs.follows = "nixpkgs";

    # Impermanence
    impermanence.url = "github:nix-community/impermanence";

    # Index Database
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";
    fh.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    impermanence,
    nix-formatter-pack,
    ...
  }@inputs:
  let
    inherit (self) outputs;
    stateVersion = "24.05";
    libx = import ./lib { inherit inputs outputs stateVersion; };
  in {
    homeConfigurations = {
      # .iso images
      "nixos@iso-console" = libx.mkHome {
        hostname = "iso-console";
        username = "nixos"; };
      "nixos@iso-gnome" = libx.mkHome {
        hostname = "iso-gnome";
        username = "nixos";
        desktop = "gnome"; };

      # Workstations
      "gabehoban@baymax" = libx.mkHome {
        hostname = "baymax";
        username = "gabehoban";
        desktop = "gnome"; };
      "gabehoban@macbook" = libx.mkHome {
        hostname = "macbook";
        username = "gabehoban";
        platform = "aarch64-darwin";
        desktop = "aqua"; };
    };
    nixosConfigurations = {
      # .iso images
      #  - nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
      iso-console  = libx.mkHost {
        hostname = "iso-console";
        username = "nixos"; };
      iso-gnome    = libx.mkHost {
        hostname = "iso-gnome";
        username = "nixos";
        desktop = "gnome"; };

      # Workstations
      #  - sudo nixos-rebuild switch --flake .#<host>
      baymax = libx.mkHost {
        hostname = "baymax";
        username = "gabehoban";
        desktop = "gnome"; };
    };

    # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
    devShells = libx.forAllSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in import ./shell.nix { inherit pkgs; }
    );

    # nix fmt
    formatter = libx.forAllSystems (system:
      nix-formatter-pack.lib.mkFormatter {
        pkgs = nixpkgs.legacyPackages.${system};
        config.tools = {
          alejandra.enable = false;
          deadnix.enable = true;
          nixpkgs-fmt.enable = true;
          statix.enable = true;
        };
      }
    );

    # Custom packages and modifications, exported as overlays
    overlays = import ./overlays { inherit inputs; };

    ciSystems =
      let
        nixos = nixpkgs.lib.genAttrs
          (builtins.attrNames inputs.self.nixosConfigurations)
          (attr: inputs.self.nixosConfigurations.${attr}.config.system.build.toplevel);
      in
        nixos;
  };
}
