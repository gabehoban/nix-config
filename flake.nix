{
  description = "jervw's NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    attic.url = "github:zhaofengli/attic";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    impermanence.url = "github:nix-community/impermanence";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.agenix-rekey.flakeModule
        ./hosts
        # ./deploy.nix
      ];

      perSystem =
        {
          pkgs,
          config,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [ config.agenix-rekey.package ];
            packages = with pkgs; [
              nixfmt-rfc-style
              deploy-rs
            ];
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              stylua.enable = true;
              deadnix.enable = true;
            };
          };

          formatter = config.treefmt.build.wrapper;
          agenix-rekey.nodes = inputs.self.nixosConfigurations;
        };
    };
}
