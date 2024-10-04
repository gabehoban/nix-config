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
    ../../modules/network
    ../../modules/hardware
    ../../modules/services
  ];

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  chaotic.scx.enable = true;
}
