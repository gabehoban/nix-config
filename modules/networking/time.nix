{ config, lib, ... }:
{
  config = {
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
        (lib.mkIf (!config.syscfg.stratum.enable) ''
          # Local Stratum 1 Servers
          server 10.32.40.51 iburst
          server 10.32.40.52 iburst

          minsources 5
        '')
        (lib.mkIf config.syscfg.stratum.enable ''
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
  };
}
