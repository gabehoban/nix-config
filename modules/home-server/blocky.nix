{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.syscfg.server;
in
{
  options.syscfg.server.blocky = lib.mkOption {
    description = "Enables Blocky DNS Server";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf cfg.blocky {
    networking = {
      resolvconf.useLocalResolver = true;
      firewall = {
        allowedTCPPorts = [
          53
          5335
        ];
        allowedUDPPorts = [
          53
          5335
        ];
      };
    };

    environment.systemPackages = [ pkgs.blocky ];

    services = {
      postgresql.enable = true;
      resolved.enable = lib.mkForce false;
      unbound = {
        enable = true;
        enableRootTrustAnchor = true;
        localControlSocketPath = "/run/unbound/unbound.ctl";
        resolveLocalQueries = true;
        package = pkgs.unbound-full;
        settings = {
          server = {
            port = "5335";
            aggressive-nsec = true;
            cache-max-ttl = 86400;
            cache-min-ttl = 300;
            delay-close = 10000;
            deny-any = true;
            do-ip4 = true;
            do-ip6 = true;
            do-tcp = true;
            do-udp = true;
            edns-buffer-size = "1472";
            extended-statistics = true;
            harden-algo-downgrade = true;
            harden-below-nxdomain = true;
            harden-dnssec-stripped = true;
            harden-glue = true;
            harden-large-queries = true;
            harden-short-bufsize = true;
            infra-cache-slabs = 8;
            interface = [
              "0.0.0.0"
              "::"
            ];
            key-cache-slabs = 8;
            msg-cache-size = "256m";
            msg-cache-slabs = 8;
            neg-cache-size = "256m";
            num-queries-per-thread = 4096;
            num-threads = 8;
            outgoing-range = 8192;
            prefetch = true;
            prefetch-key = true;
            qname-minimisation = true;
            rrset-cache-size = "256m";
            rrset-cache-slabs = 8;
            rrset-roundrobin = true;
            serve-expired = true;
            so-rcvbuf = "4m";
            so-reuseport = true;
            so-sndbuf = "4m";
            statistics-cumulative = true;
            statistics-interval = 0;
            tls-cert-bundle = "/etc/ssl/certs/ca-certificates.crt";
            unwanted-reply-threshold = 100000;
            use-caps-for-id = "no";
            verbosity = 1;
            private-address = [
              "10.0.0.0/8"
              "169.254.0.0/16"
              "172.16.0.0/12"
              "192.168.0.0/16"
              "fd00::/8"
              "fe80::/10"
            ];
            private-domain = [ "local" ];
            domain-insecure = [ "local" ];
          };
        };
      };

      blocky = {
        enable = true;
        settings = {
          connectIPVersion = "v4";
          minTlsServeVersion = "1.2";
          ports = {
            dns = 53;
            tls = 853;
            http = 4000;
          };
          upstreams = {
            strategy = "strict";
            timeout = "30s";
            init.strategy = "fast";
            groups = {
              default = [
                "tcp+udp:127.0.0.1:5335"
                "tcp-tls:dns.quad9.net"
              ];
            };
          };
          blocking = {
            loading = {
              strategy = "fast";
              concurrency = 8;
              refreshPeriod = "4h";
            };
            denylists = {
              ads = [
                "https://adaway.org/hosts.txt"
                "https://blocklistproject.github.io/Lists/ads.txt"
                "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
                "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
                "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
                "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"
                "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
                "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
                "https://v.firebog.net/hosts/AdguardDNS.txt"
                "https://v.firebog.net/hosts/Admiral.txt"
                "https://v.firebog.net/hosts/Easylist.txt"
              ];
              tracking = [
                "https://blocklistproject.github.io/Lists/smart-tv.txt"
                "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
                "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
                "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts"
                "https://v.firebog.net/hosts/Easyprivacy.txt"
                "https://v.firebog.net/hosts/Prigent-Ads.txt"
              ];
              malicious = [
                "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"
                "https://phishing.army/download/phishing_army_blocklist_extended.txt"
                "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
                "https://v.firebog.net/hosts/Prigent-Crypto.txt"
              ];
              misc = [
                "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt"
                "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"
                "https://v.firebog.net/hosts/static/w3kbl.txt"
                "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser"
              ];
              catchall = [
                "https://big.oisd.nl/domainswild"
              ];
            };
            allowlists =
              let
                customWhitelist = pkgs.writeText "misc.txt" ''
                  ax.phobos.apple.com.edgesuite.net
                  amp-api-edge.apps.apple.com
                  *.flake.sh
                  *.discord.com
                '';
              in
              {
                ads = [
                  "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
                  "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/optional-list.txt"
                ];
                misc = [ customWhitelist ];
              };
            clientGroupsBlock = {
              default = [
                "ads"
                "tracking"
                "malicious"
                "misc"
                "catchall"
              ];
            };
          };
          log = {
            level = "warn";
          };
          caching = {
            minTime = "2h";
            maxTime = "12h";
            maxItemsCount = 0;
            prefetching = true;
            prefetchExpires = "2h";
            prefetchThreshold = 5;
          };
          queryLog = {
            type = "postgresql";
            target = "postgres://blocky?host=/run/postgresql";
            logRetentionDays = 90;
          };
          prometheus.enable = true;
        };
      };
      postgresql = {
        ensureDatabases = [ "blocky" ];
        ensureUsers = [
          {
            name = "blocky";
            ensureDBOwnership = true;
          }
          {
            name = "grafana";
          }
        ];
      };
      prometheus.scrapeConfigs = [
        {
          job_name = "blocky";
          scrape_interval = "15s";
          static_configs = [ { targets = [ "127.0.0.1:4000" ]; } ];
        }
      ];
      grafana = {
        declarativePlugins = with pkgs.grafanaPlugins; [ grafana-piechart-panel ];
        settings.panels.disable_sanitize_html = true;
        provision.datasources.settings = {
          apiVersion = 1;
          datasources = [
            {
              name = "Blocky Query Log";
              type = "postgres";
              url = "/run/postgresql";
              database = "blocky";
              user = "grafana";
              orgId = 1;
            }
          ];
          deleteDatasources = [
            {
              name = "Blocky Query Log";
              orgId = 1;
            }
          ];
        };
      };
    };

    systemd.services = {
      postgresql.postStart = lib.mkAfter ''
        $PSQL -tAc 'GRANT pg_read_all_data TO grafana'
      '';
      blocky = {
        after = [
          "unbound.service"
        ];
        requires = [ "unbound.service" ];
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "blocky";
          Group = "blocky";
          Restart = "on-failure";
          RestartSec = "1";
        };
      };
    };

    users.users.blocky = {
      group = "blocky";
      isSystemUser = true;
    };

    users.groups.blocky = { };
  };
}
