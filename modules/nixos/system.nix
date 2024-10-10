{ inputs, pkgs, ... }:
{
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  environment = {
    systemPackages =
      with pkgs;
      [
        age
        any-nix-shell
        dnsutils
        file
        git
        glib
        jq
        killall
        lsof
        nh
        python3
        rage
        sops
        tpm2-tss
        unar
        unzip
        xfsprogs
        zip
      ]
      ++ [ inputs.agenix.packages.${system}.agenix ];
  };

  services = {
    logind = {
      powerKey = "ignore";
      powerKeyLongPress = "poweroff";
    };
  };

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  # allow others to mount fuse filesystems (hm-impermanence)
  programs.fuse.userAllowOther = true;

  system.stateVersion = "24.05";
}
