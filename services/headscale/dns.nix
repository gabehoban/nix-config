{
  services.headscale.settings.dns = {
    magic_dns = true;
    base_domain = "lab4.cc";

    search_domains = [ ];
    nameservers.global = [
      "100.77.0.3"
    ];
  };
}
