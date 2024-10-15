{
  config,
  lib,
  ...
}:
let
  cfg = config.syscfg.server;
in
{
  options.syscfg.server.prometheus = lib.mkOption {
    description = "Enables Prometheus Server";
    type = lib.types.bool;
    default = false;
  };
  config = lib.mkIf cfg.prometheus {
    services.prometheus = {
      enable = true;
      extraFlags = [ "--storage.tsdb.retention.time=90d" ];
      scrapeConfigs = [
        {
          job_name = "node";
          scrape_interval = "1m";
          static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
        }
        {
          job_name = "prometheus";
          scrape_interval = "1m";
          static_configs = [ { targets = [ "127.0.0.1:9090" ]; } ];
        }
      ];
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "ntp"
            "pressure"
            "systemd"
          ];
        };
      };
    };

    services.grafana.provision.datasources.settings = {
      apiVersion = 1;
      datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
          orgId = 1;
        }
      ];
      deleteDatasources = [
        {
          name = "Prometheus";
          orgId = 1;
        }
      ];
    };
  };
}
