{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ../../modules/core
    ../../modules/network
    ../../modules/server/blocky.nix
  ];

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
    git
    neovim
  ];
  hardware = {
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
    };
    deviceTree.enable = true;
  };
}
