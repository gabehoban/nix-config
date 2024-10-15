{
  config,
  lib,
  ...
}:
let
  cfg = config.syscfg.profiles;
in
{
  options.syscfg.profiles.installer = lib.mkOption {
    description = "Installer profile";
    type = lib.types.bool;
    default = false;
  };
  config = lib.mkIf cfg.installer { };
}
