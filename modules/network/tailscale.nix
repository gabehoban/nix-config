{
  inputs,
  config,
  ...
}:
{
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";
  };

  age.secrets.tailscale.rekeyFile = "${inputs.self.outPath}/secrets/tailscale.age";
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale.path;
    extraUpFlags = [ "--login-server=https://headscale.lab4.cc" ];
  };
  networking.firewall.allowedUDPPorts = [ 41641 ];
}
