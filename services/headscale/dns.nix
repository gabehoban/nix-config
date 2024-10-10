{
  services.headscale.settings.dns = {
    magic_dns = true;
    search_domains = [ ];
    nameservers.global = [
      "100.77.0.3"
    ];
  };
}
