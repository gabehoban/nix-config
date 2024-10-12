{
  self,
  pkgs,
  ...
}:
{
  imports = [
    self.nixosModules.syscfgOS
    (import ./hardware.nix)
    (import ./disk.nix)
  ];
  networking.hostName = "baymax";

  # My configuration specific settings
  syscfg = {
    autoupgrade.enable = false;

    profiles.base = true;

    graphics = {
      gnome = true;
      apps = true;
      nvidia = true;
    };

    development = {
      enable = true;
      emulation.systems = [
        "aarch64-linux"
      ];
    };

    security = {
      harden = true;
      yubikey = true;
    };

    tailscale = {
      enable = true;
    };
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "auto";
    };

    efi.canTouchEfiVariables = true;
  };

  topology.self = {
    hardware.info = "Desktop PC";
  };

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  chaotic.scx.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.05";
}
