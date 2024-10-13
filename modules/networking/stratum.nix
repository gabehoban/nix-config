{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.syscfg.stratum;
  inherit (lib)
    mkIf
    ;
in
{
  options.syscfg.stratum.enable = lib.mkOption {
    description = "Configure stratum 1 server.";
    type = lib.types.bool;
    default = false;
  };

  config = mkIf cfg.enable {
    systemd.services."serial-getty@ttyS0".enable = false;

    # TODO: Figure out a cleaner way
    services.udev.extraRules = ''
      ACTION=="add", KERNEL=="pps0", MODE="0666"
      ACTION=="add", KERNEL=="ttyS0", MODE="0666"
    '';

    services.gpsd = {
      enable = true;
      nowait = true;
      readonly = false;
      listenany = false;
      devices = [
        "/dev/ttyS0"
        "/dev/pps0"
      ];
    };

    environment.systemPackages = with pkgs; [
      gpsd
      pps-tools
      jq
    ];

    systemd.services.add-i2c-rtc = {
      description = "";
      wantedBy = [ "time-sync.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        # Inform the kernel about the (rv3028) i2c RTC
        echo "rv3028" "0x52" > /sys/class/i2c-adapter/i2c-1/new_device
      '';
    };

    boot.loader.timeout = 0;
  };
}
