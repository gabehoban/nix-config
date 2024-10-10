{
  services.headscale.settings.dns_config = {
    override_local_dns = true;
    magic_dns = true;
    base_domain = "lab4.cc";
    domains = [ ];
    nameservers = [
      "100.77.0.3"
    ];
  };
}
