{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.syscfg.stratum_1.enable = lib.mkOption {
    description = "Configure Stratum 1 NTP server.";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkMerge [
    {
      # Use chrony as timeserver.
      services.timesyncd.enable = false;

      # Don't let Nix add timeservers in chrony config, we want to manually add
      # multiple options.
      networking.timeServers = [ ];

      services.chrony = {
        enable = true;
        extraConfig = lib.mkMerge [
          ''
            # Common Pools
            pool   time.cloudflare.com iburst
            pool   time.apple.com      iburst
            pool   time.nist.gov       iburst

            # Step if adjustment >1s.
            makestep 1.0 3

            # Set DSCP for networks with QoS
            dscp 46
          ''
          (lib.mkIf (!config.syscfg.stratum_1.enable) ''
            # Local Stratum 1 Servers
            server casio.lab4.cc iburst
            server sekio.lab4.cc iburst

            minsources 5
          '')
          (lib.mkIf config.syscfg.stratum_1.enable ''
            # Server Specific Settings
            hwtimestamp *
            initstepslew 1 time.google.com
            leapsectz right/UTC
            lock_all
            log rawmeasurements measurements statistics tracking refclocks tempcomp
            log tracking measurements statistics
            maxupdateskew 100.0

            # Network Settings
            allow
            clientloglimit 10000000
            ratelimit interval 1 burst 16 leak 2

            # Directories
            driftfile /var/lib/chrony/chrony.drift
            logdir /var/log/chrony
            ntsdumpdir /var/lib/chrony

            # Configure NUMA Time Sources
            refclock SHM 0 poll 8 refid NMEA offset 0.0339 precision 1e-3 poll 3 noselect
            refclock PPS /dev/pps0 refid PPS lock NMEA maxlockage 2 poll 4 precision 1e-7 prefer
          '')
        ];
      };
    }
    (lib.mkIf config.syscfg.stratum_1.enable {
      # Disable getty console on /dev/ttyS0
      systemd.services."serial-getty@ttyS0".enable = false;

      # Widen permissions on GPIO devices for Chrony and GPSD
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

      # Manually initialize RTC module in RPI hat
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
    })
  ];
}
