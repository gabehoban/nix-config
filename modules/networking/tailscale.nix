{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
let
  cfg = config.syscfg.tailscale;
  inherit (lib)
    mkMerge
    mkIf
    ;
in
{
  options.syscfg.tailscale.enable = lib.mkOption {
    description = "Configure tailscale client.";
    type = lib.types.bool;
    default = false;
  };

  config = mkMerge [
    (mkIf cfg.enable {
      networking.firewall = {
        trustedInterfaces = [ "tailscale0" ];
        allowedUDPPorts = [ config.services.tailscale.port ];
      };

      topology.self.interfaces.tailscale0 = {
        addresses = [ config.networking.hostName ];
        network = "tailscale0";
        virtual = true;
        type = "tun";
      };

      sops.secrets = {
        tailscale-auth = {
          sopsFile = ../../secrets/all.yaml;
        };
      };

      services.tailscale = {
        enable = true;
        permitCertUid = "root";
        useRoutingFeatures = lib.mkDefault "both";
        authKeyFile = config.sops.secrets.tailscale-auth.path;
        extraUpFlags = [
          "--login-server=https://headscale.labrats.cc"
          "--accept-routes"
          "--operator=${vars.user}"
          "--ssh"
        ];
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
            ${pkgs.tailscale}/bin/tailscale up --auth-key 'file:${config.sops.secrets.tailscale-auth.path}' ${toString config.services.tailscale.extraUpFlags}
          '';
        };
      };
    })
  ];
}
