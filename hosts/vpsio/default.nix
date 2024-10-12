{
  self,
  pkgs,
  vars,
  lib,
  ...
}:
{
  imports = [
    self.nixosModules.syscfgOS
    (import ./hardware.nix)
    (import ./disks.nix)
  ];
  networking.hostName = "vpsio";

  boot.loader = {
    grub.devices = lib.mkDefault [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_52633424" ];
    grub.configurationLimit = lib.mkDefault 3;
  };

  syscfg = {
    autoupgrade.enable = false;
    profiles.base      = true;
    profiles.server    = true;
    # profiles.webserver = true;

    security.harden = true;

    tailscale = {
      enable = false;
    };
  };

  topology.self = {
    hardware.info = "NixOS VPS Cloud Server";
  };

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  chaotic.scx.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.05";
}
