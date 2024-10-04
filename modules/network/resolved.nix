{
  services = {
    resolved = {
      enable = true;

      # this is necessary to get tailscale picking up your headscale instance
      # and allows you to ping connected hosts by hostname
      domains = [ "~." ];

      dnssec = "false";
      extraConfig = ''
        DNSOverTLS=yes # or allow-downgrade
      '';

      # Fallback dns servers will be used if the primary dns servers are not reachable
      # Here we are using quad9 as the fallback dns server
      fallbackDns = [ "9.9.9.9" ];
    };
  };
}
