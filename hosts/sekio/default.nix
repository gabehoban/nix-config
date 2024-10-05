{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ../../modules/core
    # ../../modules/network
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
