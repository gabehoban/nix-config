{
  config,
  pkgs,
  lib,
  vars,
  inputs,
  ...
}:
let
  cfg = config.syscfg;
in
{
  imports = [
    inputs.attic.nixosModules.atticd
    inputs.chaotic.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops
  ] ++ (import ./modules-list.nix);

  config = {
    # Setup home-manager
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        inputs.nix-index-database.hmModules.nix-index
        inputs.nixvim.homeManagerModules.nixvim
        inputs.sops-nix.homeManagerModules.sops
      ];
    };

    # Setup sops-nix
    sops = {
      defaultSopsFile = ../secrets/all.yaml;
      defaultSopsFormat = "yaml";

      secrets = {
        user-passwd = {
          sopsFile = ../secrets/all.yaml;
          neededForUsers = true;
        };
        github-token = {
          sopsFile = ../secrets/all.yaml;
          owner = vars.user;
        };
      };
    };

    users = {
      mutableUsers = false;
      groups.plugdev = { };
      users = {
        ${vars.user} = {
          isNormalUser = true;
          uid = 1000;
          extraGroups = [
            "plugdev"
            "dialout"
            "video"
            "audio"
            "disk"
            "networkmanager"
            "wheel"
            "kvm"
          ];
          description = cfg.fullname;
          hashedPasswordFile = config.sops.secrets.user-passwd.path;
        };
        root.hashedPasswordFile = config.sops.secrets.user-passwd.path;
      };
    };

    home-manager.users.${vars.user} = {
      home.stateVersion = "24.05";
      home.sessionPath = [ "$HOME/.bin" ];

      nixpkgs.config.allowUnfree = true;
    };

    time.timeZone = cfg.timezone;
    i18n.defaultLocale = "en_US.UTF-8";

    # We enable DHCP for all network interfaces by default.
    networking.useDHCP = lib.mkDefault true;

    nix = {
      settings = {
        allowed-users = [ cfg.username ];
        builders-use-substitutes = true;
        trusted-users = [
          "root"
          cfg.username
        ];
        auto-optimise-store = true;

        # Enable flakes
        experimental-features = [
          "flakes"
          "nix-command"
          "recursive-nix"
          "ca-derivations"
          "auto-allocate-uids"
          "cgroups"
          "no-url-literals"
          "dynamic-derivations"
        ];
        substituters = [
          "https://nix-cache.lab4.cc/main"
          "https://nix-community.cachix.org"
          "https://nyx.chaotic.cx"
        ];
        trusted-public-keys = [
          "main:OgEYxQaDFUQ00yzsyGBHamozb35sBqNmq5/DONu0oeY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        ];
        system-features = [
          "nixos-test"
          "kvm"
          "recursive-nix"
          "big-parallel"
        ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      # API Rate limit for GitHub
      extraOptions = ''
        !include ${config.sops.secrets.github-token.path}
      '';
    };

    # Use spleen font for console (tty)
    fonts.packages = [ pkgs.spleen ];
    console.font = "${pkgs.spleen}/share/consolefonts/spleen-12x24.psfu";

    services.getty = {
      greetingLine = lib.mkOverride 50 ''<<< Welcome to ${config.networking.hostName} (\l) >>>'';
      helpLine = lib.mkOverride 50 ''Help: https://github.com/gabehoban/nix-config'';
    };

    hardware.enableAllFirmware = true;
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowBroken = true;
        allowUnsupportedSystem = true;
      };
    };
  };
}
