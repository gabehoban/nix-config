_: {
  services = {
    endlessh-go = {
      enable = true;
      port = 22;
      prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 2112;
      };
      openFirewall = true;
    };
    prometheus.scrapeConfigs = [
      {
        job_name = "endless_ssh";
        scrape_interval = "15s";
        static_configs = [ { targets = [ "127.0.0.1:2112" ]; } ];
      }
    ];
  };
}
