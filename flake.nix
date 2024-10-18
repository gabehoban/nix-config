{
  description = "syscfg is a declarative system configuration built by Humaid";

  nixConfig = {
    #    extra-substituters = [ "https://cache.huma.id" ];
    #    extra-trusted-public-keys = [ "cache.huma.id:YJG69WGZ8iUFwrZFrXbLY50m9jXNmJUas1vwtksUFFM=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    impermanence.url = "github:nix-community/impermanence";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:inclyc/flake-compat";
      flake = false;
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          inherit (nixpkgs) lib;
          vars = {
            user = "gabehoban";
          };
        };
      }
      {
        imports = [
          inputs.flake-root.flakeModule
          inputs.git-hooks.flakeModule
          inputs.treefmt-nix.flakeModule
          ./hosts
        ];
        flake = {
          nixosModules = {
            syscfgOS = import ./modules;
          };
        };
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];
        perSystem =
          {
            config,
            system,
            pkgs,
            ...
          }:
          {
            devShells.default = pkgs.mkShell {
              inputsFrom = [ config.flake-root.devShell ];
              shellHook = ''
                ${config.pre-commit.installationScript}
              '';
              packages = with pkgs; [
                just
                attic-client
              ];
            };

            pre-commit = {
              check.enable = true;
              settings.hooks = {
                nil.enable = true;
                statix.enable = true;
                treefmt.enable = true;
              };
            };

            treefmt.config = {
              package = pkgs.treefmt;
              inherit (config.flake-root) projectRootFile;
              settings.global.excludes = [
                "*.yaml"
                "*.yml"
                "*.png"
                "*.json"
                "*.md"
                "./modules/home-server/headscale.nix"
              ];
              programs = {
                nixfmt.enable = true;
                nixfmt.package = pkgs.nixfmt-rfc-style;
                deadnix.enable = true;
                statix.enable = true;
              };
            };
            formatter = config.treefmt.build.wrapper;
            _module.args = {
              pkgs = import inputs.nixpkgs {
                inherit system inputs;
                config.allowUnfree = true;
              };
            };
          };
      };
}
