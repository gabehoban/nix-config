{ config
, pkgs
, inputs
, lib
, ...
}:
let
  inherit (inputs)
    self
    nixos-hardware
    home-manager
    lanzaboote
    ;
in
{
  imports =
    (lib.singleton ./hardware-configuration.nix)
    ++ (lib.attrValues {
      inherit (lanzaboote.nixosModules) lanzaboote;
      inherit (home-manager.nixosModules) home-manager;
      inherit (nixos-hardware.nixosModules)
        common-pc-ssd
        ;
      inherit (self.nixosModules)
        nix
        nixpkgs
        pc
        packages
        virt-manager
        hm
        users
        gnome
        zram
        pipewire
        ;
    });

  networking.hostName = "baymax";

  # Bootloader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.loader.timeout = 0;
  boot.initrd.systemd.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # dbus-broker is more performant
  services.dbus.implementation = "broker";

  # systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  networking.useDHCP = true;
  nix.settings.max-jobs = 4;

  time.timeZone = "America/New_York";

  services.pipewire.extraConfig.pipewire."99-rates" = {
    "context.properties" = {
      "default.clock.rate" = 96000;
      "default.clock.allowed-rates" = [ 44100 48000 88200 96000 ];
    };
  };

  services.pipewire.wireplumber.extraConfig."99-stop-microphone-auto-adjust" = {
    "access.rules" = [
      {
        matches = [
          {
            "application.process.binary" = "chrome";
          }
          {
            "application.process.binary" = "electron";
          }
        ];
        actions.update-props.default_permissions = "rx";
      }
    ];
  };

  # Configure GPU
  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.opengl = {
    enable = true;
    # if hardware.opengl.driSupport is enabled, mesa is installed and provides Vulkan for supported hardware.
    driSupport = true;
    # needed by nvidia-docker
    driSupport32Bit = true;
  };
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    modesetting.enable = true;
    powerManagement.enable = true;
  };

  # Gaming
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  home-manager.users.gabehoban = import ./home.nix;

  system.stateVersion = "24.05";
}
