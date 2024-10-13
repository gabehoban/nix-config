{
  self,
  pkgs,
  ...
}:
{
  imports = [
    self.nixosModules.syscfgOS
    (import ./hardware.nix)
    (import ./disks.nix)
    (import ./persist.nix)
  ];
  networking.hostName = "srvio";

  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "auto";
    };

    efi.canTouchEfiVariables = true;
  };

  syscfg = {
    autoupgrade.enable = false;
    profiles.base = true;
    profiles.server = true;
    # profiles.webserver = true;

    development = {
      enable = true;
      emulation.systems = [
        "aarch64-linux"
      ];
    };

    security.harden = true;

    tailscale = {
      enable = true;
    };
  };

  sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";

  topology.self = {
    hardware.info = "NixOS Homelab Server";
  };

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  chaotic.scx.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.05";
}
