{ config, lib, ... }:
let
  cfg = config.syscfg;
in
{
  options.syscfg.autoupgrade.enable = lib.mkEnableOption "autoupgrades";
  config = lib.mkIf cfg.autoupgrade.enable {
    system.autoUpgrade = {
      enable = true;
      allowReboot = true;
      randomizedDelaySec = "45min";
      rebootWindow = {
        lower = "01:00";
        upper = "05:00";
      };
      dates = "01:30";
      flake = "github:gabehoban/nix-config#${config.networking.hostName}";
      flags = [
        "--refresh"
        "-L"
      ];
    };
  };
}
