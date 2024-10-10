{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.chaotic.nixosModules.default

    ./hardware-configuration.nix
    ../../modules/profiles/baymax.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  chaotic.scx.enable = true;
}
