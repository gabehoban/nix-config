{
  config,
  ...
}:
{
  services = {
    headscale = {
      enable = true;
      port = 8085;
      address = "127.0.0.1";
      settings = {
        dns_config = {
          base_domain = "lab4.cc";
          magic_dns = true;
          nameservers = [ "9.9.9.9" ];
          override_local_dns = true;
          use_username_in_magic_dns = false;
        };
        server_url = "https://headscale.lab4.cc";
        metrics_listen_addr = "127.0.0.1:8095";
        logtail = {
          enabled = false;
        };
        log = {
          level = "info";
        };
        ip_prefixes = [
          "100.77.0.0/24"
          "fd7a:115c:a1e0:77::/64"
        ];
        derp.server = {
          enable = true;
          region_id = 999;
          stun_listen_addr = "0.0.0.0:3478";
        };
      };
    };

    nginx.virtualHosts = {
      "headscale.lab4.cc" = {
        forceSSL = true;
        enableACME = true;
        quic = true;
        http3 = true;
        locations = {
          "/" = {
            proxyPass = "http://localhost:${toString config.services.headscale.port}";
            proxyWebsockets = true;
          };
        };
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
        '';
      };
    };
  };

  # Derp server
  networking.firewall.allowedUDPPorts = [ 3478 ];
  environment.systemPackages = [ config.services.headscale.package ];
}
