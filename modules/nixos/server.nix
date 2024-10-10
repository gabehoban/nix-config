{ lib, ... }:
{
  fonts.fontconfig.enable = lib.mkDefault false;
  programs.command-not-found.enable = lib.mkDefault false;

  # No mutable users by default
  users.mutableUsers = false;

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

  virtualisation.vmVariant.virtualisation.graphics = lib.mkDefault false;
}
