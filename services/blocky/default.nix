{ pkgs, lib, ... }:
{
  imports = [
    ../unbound
    ../postgres
  ];

  networking.firewall.allowedTCPPorts = [
    53
    5335
  ];
  networking.firewall.allowedUDPPorts = [
    53
    5335
  ];

  environment.systemPackages = [ pkgs.blocky ];

  services = {
    blocky = {
      enable = true;
      settings = {
        connectIPVersion = "v4";
        upstreamTimeout = "5s";
        minTlsServeVersion = "1.2";
        ports = {
          dns = 53;
          tls = 853;
        };
        upstream.default = [ "127.0.0.1:5335" ];
        startVerifyUpstream = true;
        blocking = {
          loading = {
            strategy = "fast";
            concurrency = 8;
            refreshPeriod = "4h";
          };
          blackLists = {
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
              "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
              "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
              "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
              "https://v.firebog.net/hosts/Prigent-Crypto.txt"
              "https://v.firebog.net/hosts/RPiList-Malware.txt"
              "https://v.firebog.net/hosts/RPiList-Phishing.txt"
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
          whiteLists =
            let
              customWhitelist = pkgs.writeText "misc.txt" ''
                ax.phobos.apple.com.edgesuite.net
                amp-api-edge.apps.apple.com
                (\.|^)dscx\.akamaiedge\.net$
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
        prometheus = {
          enable = true;
          path = "/metrics";
        };
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
        "postgresql.service"
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

}
