{
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disks.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    loader = {
      grub.enable = lib.mkForce false;
      generic-extlinux-compatible.enable = lib.mkForce true;
    };
    initrd.availableKernelModules = [ ];
    initrd.kernelModules = [ ];
    initrd.systemd.tpm2.enable = lib.mkForce false;
    kernelModules = [
      "bridge"
      "macvlan"
      "tap"
      "tun"
      "loop"
      "atkbd"
      "ctr"
    ];
    extraModulePackages = [ ];
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
