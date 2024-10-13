{ lib, config, ... }:
let
  cfg = config.syscfg.server;
in
{
  options.syscfg.server.headscale = lib.mkOption {
    description = "Enables Headscale Server";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf cfg.headscale {
    networking.firewall.allowedUDPPorts = [ 3478 ];

    sops.secrets = {
      headscale-private-key = {
        owner = "headscale";
        sopsFile = ../../secrets/headscale.yaml;
      };
      headscale-noise-private-key = {
        owner = "headscale";
        sopsFile = ../../secrets/headscale.yaml;
      };
    };

    environment.systemPackages = [ config.services.headscale.package ];

    services.headscale = {
      enable = true;
      address = "127.0.0.1";
      port = 8085;

      settings = {
        # grpc
        grpc_listen_addr = "127.0.0.1:50443";
        grpc_allow_insecure = false;

        server_url = "https://headscale.labrats.cc";
        tls_cert_path = null;
        tls_key_path = null;

        noise = {
          private_key_path = config.sops.secrets.headscale-noise-private-key.path;
        };

        # default headscale prefix
        prefixes = {
          v6 = "fd7a:115c:a1e0::/48";
          v4 = "100.64.0.0/10";
          allocation = "random";
        };

        # database
        database = {
          type = "sqlite";
          sqlite.path = "${config.users.users.headscale.home}/db.sqlite";
        };

        # misc
        randomize_client_port = false;
        disable_check_updates = true;
        ephemeral_node_inactivity_timeout = "30m";
        node_update_check_interval = "10s";

        # logging
        log = {
          format = "text";
          level = "info";
        };

        logtail.enabled = false;

        derp = {
          server = {
            enabled = true;
            stun_listen_addr = "0.0.0.0:3478";
            region_code = "headscale";
            region_name = "Headscale Embedded DERP";
            region_id = 999;
            private_key_path = config.sops.secrets.headscale-private-key.path;
          };
          urls = [ ];
          paths = [ ];
          auto_update_enabled = false;
          update_frequency = "6h";
        };
        dns = {
          magic_dns = true;
          base_domain = "lab4.cc";

          search_domains = [ ];
          nameservers.global = [
            "100.80.65.16" # Sekio
          ];
          extra_records = [
            {
              name = "hydra.lab4.cc";
              type = "A";
              value = "100.77.210.83";
            }
            {
              name = "nix-cache.lab4.cc";
              type = "A";
              value = "100.77.210.83";
            }
          ];
        };
      };
    };
    services.nginx.virtualHosts."headscale.labrats.cc" = {
      forceSSL = true;
      enableACME = true;
      quic = true;
      http3 = true;

      locations = {
        "/" = {
          proxyPass = "http://localhost:${toString config.services.headscale.port}";
          proxyWebsockets = true;
          extraConfig = ''
            keepalive_requests          100000;
            keepalive_timeout           160s;
            proxy_buffering             off;
            proxy_connect_timeout       75;
            proxy_ignore_client_abort   on;
            proxy_read_timeout          900s;
            proxy_send_timeout          600;
            send_timeout                600;
          '';
        };
      };

      extraConfig = ''
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
      '';
    };
  };
}
