{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.chaotic.nixosModules.default

    ./hardware-configuration.nix

    ../../modules/core
    ../../modules/nixos
    ../../modules/virtualisation
    ../../modules/network
    ../../modules/hardware
    ../../modules/services
  ];

  networking.hostId = "007f0200";
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  chaotic.scx.enable = true;
}
