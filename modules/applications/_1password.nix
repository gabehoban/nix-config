{
  config,
  lib,
  ...
}:
let
  cfg = config.syscfg.applications;
in
{
  options.syscfg.applications._1password.enable = lib.mkOption {
    description = "Enables 1Password configurations";
    type = lib.types.bool;
    default = config.syscfg.graphics.apps;
  };
  config = lib.mkIf cfg._1password.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "gabehoban" ];
    };
  };
}
