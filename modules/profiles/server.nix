{ config, lib, ... }:
let
  cfg = config.syscfg.profiles;
in
{
  options.syscfg.profiles.server = lib.mkOption {
    description = "Server profile";
    type = lib.types.bool;
    default = false;
  };
  config = lib.mkIf cfg.server {
    fonts.fontconfig.enable = lib.mkDefault false;
    systemd = {
      enableEmergencyMode = false;

      watchdog = {
        runtimeTime = "20s";
        rebootTime = "30s";
      };

      sleep.extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
      '';
    };
  };
}
