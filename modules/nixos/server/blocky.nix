{ pkgs, ... }: {
  services.blocky = {
    enable = true;

    settings = {
      ports.dns = 53;
      upstreams.groups.default = [ "https://dns.quad9.net/dns-query" ];
      bootstrapDns = { ips = [ "1.1.1.1" "1.0.0.1" ]; };
      blocking = {
        blackLists = {
          ads = [
            "https://big.oisd.nl/domainswild"
          ];
        };
        clientGroupsBlock = {
          default = [ "ads" ];
        };
      };
    };
  };
}
