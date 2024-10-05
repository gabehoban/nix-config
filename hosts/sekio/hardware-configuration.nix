{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disks.nix
  ];

  loader.grub.enable = lib.mkForce false;
  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "bridge"
    "macvlan"
    "tap"
    "tun"
    "loop"
    "atkbd"
    "ctr"
  ];
  boot.extraModulePackages = [ ];
  supportedFilesystems = [
    "ext4"
    "vfat"
  ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
