{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    services.dbus.apparmor = "enabled";

    environment.systemPackages = with pkgs; [
      apparmor-pam
      apparmor-utils
      apparmor-parser
      apparmor-profiles
      apparmor-bin-utils
      apparmor-kernel-patches
      libapparmor
    ];

    # apparmor configuration
    security.apparmor = {
      enable = true;
      enableCache = true;
      killUnconfinedConfinables = true;
      packages = [ pkgs.apparmor-profiles ];
      policies = {
        "default_deny" = {
          enforce = false;
          enable = false;
          profile = ''
            profile default_deny /** { }
          '';
        };

        "sudo" = {
          enforce = false;
          enable = false;
          profile = ''
            ${pkgs.sudo}/bin/sudo {
              file /** rwlkUx,
            }
          '';
        };

        "nix" = {
          enforce = false;
          enable = false;
          profile = ''
            ${config.nix.package}/bin/nix {
              unconfined,
            }
          '';
        };
      };
    };
  };
}
