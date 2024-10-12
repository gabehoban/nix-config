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
    inputs.chaotic.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
    inputs.nix-topology.nixosModules.default
    inputs.sops-nix.nixosModules.sops
  ] ++ (import ./modules-list.nix);

  config = {
    # Setup home-manager
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.sharedModules =
      [
        inputs.sops-nix.homeManagerModules.sops
        inputs.nixvim.homeManagerModules.nixvim
        inputs.nix-index-database.hmModules.nix-index
      ];
    topology.self.name = config.networking.hostName;

    topology.networks.tailscale0 = {
      name = "Tailscale";
      cidrv4 = "100.64.0.0/10";
    };

    topology.networks.home = {
      name = "Home LAN";
      cidrv4 = "192.168.1.0/24";
    };

    # Setup sops-nix
    sops = {
      defaultSopsFile = ../secrets/all.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = "/persist/var/lib/sops-nix/key.txt";
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

    # Define default system user.
    users.mutableUsers = false;
    users.users.${vars.user} = {
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
    users.groups.plugdev = { };

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
      settings = rec {
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
          "repl-flake"
          "no-url-literals"
          "dynamic-derivations"
        ];
        substituters = [
          "https://cache.nixos.org?priority=10"
          "https://cache.lab4.cc/main"
          "https://nix-community.cachix.org"
          "https://nyx.chaotic.cx"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "main:swo2iC3lOlH6MAGDdH8F3YglXfxMCEd9oksQg++QbS8="
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
      overlays = [
        (_final: prev: {
          liquidctl = import ../overlays/liquidctl { inherit prev; };
        })
      ];
    };
    environment.persistence."/persist" = {
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/sops-nix"
        {
          directory = "/var/lib/private";
          mode = "0700";
        }
      ];
    };
  };
}
