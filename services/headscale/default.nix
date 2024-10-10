{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./acls.nix
    ./derp.nix
    ./dns.nix
  ];

  environment.systemPackages = [ config.services.headscale.package ];
  networking.firewall.allowedUDPPorts = [
    3478
    8086
  ];

  services = {
    headscale = {
      enable = true;
      address = "127.0.0.1";
      port = 8085;

      settings = {
        # grpc
        grpc_listen_addr = "127.0.0.1:50443";
        grpc_allow_insecure = false;

        server_url = "https://headscale.labrats.cc";
        base_domain = "lab4.cc";
        tls_cert_path = null;
        tls_key_path = null;

        # default headscale prefix
        ip_prefixes = [
          "100.77.0.0/24"
          "fd7a:115c:a1e0:77::/64"
        ];

        # database
        db_type = "sqlite3";
        db_path = "/var/lib/headscale/db.sqlite";
        db_name = "headscale";
        db_user = config.services.headscale.user;

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
      };
    };

    nginx.virtualHosts."headscale.labrats.cc" = {
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

  systemd.services = {
    tailscaled.after = [ "headscale.service" ];
    headscale = {
      environment = {
        HEADSCALE_EXPERIMENTAL_FEATURE_SSH = "1";
        HEADSCALE_DEBUG_TAILSQL_ENABLED = "1";
        HEADSCALE_DEBUG_TAILSQL_STATE_DIR = "${config.users.users.headscale.home}/tailsql";
      };
    };

    create-headscale-user = {
      description = "Create a headscale user and preauth keys for this server";

      wantedBy = [ "multi-user.target" ];
      after = [ "headscale.service" ];

      serviceConfig = {
        Type = "oneshot";
        User = "headscale";
      };

      path = [ pkgs.headscale ];
      script = ''
        if ! headscale users list | grep gabehoban; then
          headscale users create gabehoban
          headscale --user gabehoban preauthkeys create --reusable --expiration 100y > /var/lib/headscale/preauth.key
        fi
      '';
    };
  };
}
