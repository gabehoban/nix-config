{
  self,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    self.nixosModules.syscfgOS
    (import ./hardware.nix)
    (import ./disks.nix)
    (import ./persist.nix)
  ];
  networking.hostName = "vpsio";

  boot.loader = {
    grub.devices = lib.mkDefault [ "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_52633424" ];
    grub.configurationLimit = lib.mkDefault 3;
  };

  syscfg = {
    autoupgrade.enable = true;
    profiles.base = true;
    profiles.server = true;

    security.harden = true;

    server = {
      nginx = true;
      headscale = true;
    };

    tailscale = {
      enable = true;
    };
  };

  sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  chaotic.scx.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.05";
}
