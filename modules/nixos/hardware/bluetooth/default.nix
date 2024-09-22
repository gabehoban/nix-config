{ pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;

    package = pkgs.bluez-experimental;
    powerOnBoot = true;

    settings = {
      General = {
        Experimental = true;
        JustWorksRepairing = "always";
        MultiProfile = "multiple";
      };
    };
  };

  boot.kernelParams = [ "btusb" ];

  services.blueman = {
    enable = true;
  };
}
