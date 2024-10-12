{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.syscfg.timezone = mkOption {
    description = "Sets the timezone";
    type = types.str;
    default = "America/New_York";
  };
  # TODO move for git
  options.syscfg.username = mkOption {
    description = "Short username of the system user";
    type = types.str;
    default = "gabehoban";
  };
  options.syscfg.fullname = mkOption {
    description = "Full name of the system user";
    type = types.str;
    default = "Gabe Hoban";
  };
  options.syscfg.hardware.vm = mkOption {
    description = "Enables VM hardware specific configurations.";
    type = types.bool;
    default = false;
  };
  options.syscfg.banner = mkOption {
    description = "System use banner";
    type = types.str;
    default = ''
      You are accessing a private computer system.
      Unauthorised use of the system is prohibited and subject to criminal and civil penalties.
    '';
  };
}
