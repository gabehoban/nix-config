{
  inputs,
  config,
  lib,
  user,
  pkgs,
  ...
}:
{
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";
    allowedUDPPorts = [ 41641 ];
  };

  age.secrets.tailscale.rekeyFile = "${inputs.self.outPath}/secrets/tailscale.age";
  services.tailscale = {
    enable = true;
    permitCertUid = "root";
    useRoutingFeatures = lib.mkDefault "both";
    authKeyFile = config.age.secrets.tailscale.path;
    extraUpFlags = [
      "--login-server=https://headscale.lab4.cc"
      "--advertise-tags=tag:client"
      "--accept-routes"
      "--operator=${user}"
      "--ssh"
    ];
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };
  systemd.services = {
    tailscaled.serviceConfig.Environment = lib.mkBefore [
      "TS_NO_LOGS_NO_SUPPORT=true"
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];
    tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";
      after = [
        "network-pre.target"
        "tailscale.service"
      ];
      wants = [
        "network-pre.target"
        "tailscale.service"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to Tailscale
        status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"

        # if so, then do nothing
        if [[ $status = "Running" ]]; then
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${pkgs.tailscale}/bin/tailscale up --auth-key 'file:${config.services.tailscale.authKeyFile}' ${toString config.services.tailscale.extraUpFlags}
      '';
    };
  };
}
