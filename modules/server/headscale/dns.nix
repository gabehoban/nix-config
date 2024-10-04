{
  services.headscale.settings.dns_config = {
    override_local_dns = true;
    magic_dns = true;
    base_domain = "lab4.cc";
    domains = [ ];
    nameservers = [
      "9.9.9.9"
    ];
  };
}
