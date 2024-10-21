{
  config,
  lib,
  pkgs,
  ...
}:
let
  chrony-exporter = pkgs.callPackage ../../pkgs/chrony-exporter.nix { };
  gpsd-exporter = pkgs.callPackage ../../pkgs/gpsd-exporter.nix { };
in
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
            pool   time.cloudflare.com iburst minpoll 5 maxpoll 5 polltarget 16 maxdelay 0.030 maxdelaydevratio 2 maxsources 6
            pool   time.apple.com      iburst minpoll 5 maxpoll 5 polltarget 16 maxdelay 0.030 maxdelaydevratio 2 maxsources 6
            pool   time.nist.gov       iburst minpoll 5 maxpoll 5 polltarget 16 maxdelay 0.030 maxdelaydevratio 2 maxsources 6

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
            refclock SHM 0 poll 8 refid GPS precision 1e-1 offset 0.090 delay 0.2 noselect
            refclock SHM 1 refid PPS precision 1e-7 prefer
            refclock PPS /dev/pps0 lock GPS maxlockage 2 poll 4 refid kPPS precision 1e-7 prefer
          '')
        ];
      };
    }
    (lib.mkIf config.syscfg.stratum_1.enable {
      # Disable getty console on /dev/ttyS0
      systemd.services."serial-getty@ttyS0".enable = false;

      # Force cpu power mode
      powerManagement.cpuFreqGovernor = "performance";

      # Widen permissions on GPIO devices for Chrony and GPSD
      services.udev.extraRules = ''
        ACTION=="add", KERNEL=="pps0", MODE="0666"
        ACTION=="add", KERNEL=="ttyS0", MODE="0666, RUN+="${pkgs.setserial}/bin/setserial /dev/ttyAMA0 low_latency"
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
        extraArgs = [
          "--badtime"
          "--passive"
          "--speed=115200"
        ];
      };
      environment.systemPackages = with pkgs; [
        gpsd
        i2c-tools
        jq
        minicom
        pps-tools
        python312Packages.smbus2
        setserial
      ];

      sops.secrets."service_options" = {
        sopsFile = ../../secrets/gpsd.yaml;
      };
      services = {
        prometheus.scrapeConfigs = [
          {
            job_name = "chrony";
            scrape_interval = "15s";
            static_configs = [ { targets = [ "127.0.0.1:9123" ]; } ];
          }
          {
            job_name = "gpsd";
            scrape_interval = "15s";
            static_configs = [ { targets = [ "127.0.0.1:9101" ]; } ];
          }
        ];
      };
      systemd.services.chrony-exporter = {
        description = "chrony-exporter";
        wants = [
          "network.target"
          "chronyd.service"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          User = "root";
          ExecStart = ''${chrony-exporter}/bin/chrony_exporter --no-collector.dns-lookups'';
        };
      };
      systemd.services.gpsd-exporter = {
        description = "gpsd-exporter";
        wants = [
          "network.target"
          "gpsd.service"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          User = "root";
          ExecStart = ''${gpsd-exporter}/bin/gpsd-exporter'';
        };
      };
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
