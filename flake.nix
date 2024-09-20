{
  description = "NixOS and Home Manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hardware.url = "github:nixos/nixos-hardware/master";
    nix-colors.url = "github:misterio77/nix-colors";
    sops-nix.url = "github:Mic92/sops-nix";
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      hyprland,
      hardware,
      nix-colors,
      sops-nix,
      impermanence,
      disko,
      nixos-cosmic,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      defaultModules = [
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        sops-nix.nixosModules.sops
      ];

      homeManagerServerModule = [
        home-manager.nixosModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs outputs;
          };
          home-manager.users.gabehoban = {
            # Import impermanence to home-manager
            imports = [
              (impermanence + "/home-manager.nix")
              ./home/gabehoban/server.nix
            ];
          };
          home-manager.backupFileExtension = "bak";
        }
      ];

    in
    rec {
      overlays = import ./overlays/unstable-pkgs.nix { inherit inputs; };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

      # NixOS Configs
      nixosConfigurations = {
        # Main Desktop 
        "pc-baymax" = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          system = "x86_64-linux";
          modules = defaultModules ++ [
            nixos-cosmic.nixosModules.default
            ./hosts/pc-baymax/configuration.nix
            {
              nix.settings = {
                substituters = [ "https://cosmic.cachix.org/" ];
                trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
              };
            }
            hardware.nixosModules.common-gpu-nvidia-nonprime
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs outputs;
              };
              home-manager.users.gabehoban = {
                # Import impermanence to home-manager
                imports = [
                  # (impermanence + "/home-manager.nix")
                  ./home/gabehoban/pc-baymax.nix
                ];
              };
              home-manager.backupFileExtension = "bak";
            }
          ];
        };

        # Backup Server
        # "maul" = nixpkgs.lib.nixosSystem {
        #   specialArgs = {inherit inputs outputs;};
        #   system = "x86_64-linux";
        #   modules = defaultModules ++ homeManagerServerModule ++ [
        #     ./hosts/maul/configuration.nix
        #   ];
        # };

      };
    };
}
