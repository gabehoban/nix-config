{
  config,
  lib,
  ...
}:
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
        lower = "04:00";
        upper = "07:00";
      };
      flake = "github:gabehoban/nix-config#${config.networking.hostName}";
      flags = [
        "--refresh"
        "-L"
      ];
    };
  };
}
