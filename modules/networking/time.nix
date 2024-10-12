{ config, lib, ... }:
let
  cfg = config.syscfg.ntp;
in
{
  config = {
    # Use chrony as timeserver. Although chrony is more heavy (includes server
    # implementation), but it implements full NTP protocol.
    services.timesyncd.enable = false;

    # Don't let Nix add timeservers in chrony config, we want to manually add
    # multiple options.
    networking.timeServers = [ ];

    services.chrony = {
      enable = true;
      extraConfig = ''
        pool   time.cloudflare.com prefer iburst xleave nts
        server ohio.time.system76.com     iburst xleave nts
        server virginia.time.system76.com iburst xleave nts

        # Step if adjustment >1s.
        makestep 1.0 3

        # Set DSCP for networks with QoS
        dscp 46

        minsources 5
      '';
    };
    environment.persistence."/persist".directories = [ "/var/lib/chrony" ];
  };
}
