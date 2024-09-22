_: {
  services.avahi = {
    enable = true;

    # resolve .local domains
    nssmdns4 = true;

    # pass avahi port(s) to the firewall
    openFirewall = true;

    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };
}
