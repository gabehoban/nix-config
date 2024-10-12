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
    mkOption
    types
    mkMerge
    mkIf
    mkEnableOption
    ;
in
{
  options.syscfg.tailscale = {
    enable = mkEnableOption "Tailscale configuration";
    exitNode = mkEnableOption "exit node configuration";
    ssh = mkOption {
      description = "Enables openssh for access through tailscale only";
      type = types.bool;
      default = true;
    };
    auth = mkOption {
      description = "Performs a oneshot authentication with an auth-key";
      type = types.bool;
      default = true;
    };
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

      services.tailscale = {
        enable = true;
        permitCertUid = "root";
        useRoutingFeatures = lib.mkDefault "both";
        authKeyFile = config.age.secrets.tailscale.path;
        extraUpFlags = [
          "--login-server=https://headscale.labrats.cc"
          "--advertise-tags=tag:client"
          "--accept-routes"
          "--operator=${vars.user}"
          "--ssh"
        ];
      };

      services.openssh = {
        enable = true;

        # Security: do not allow password auth or root login.
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };

        # Do not open firewall rules, tailscale can access only.
        openFirewall = false;
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
      environment.persistence."/persist" = {
        directories = [ "/var/lib/tailscale" ];
      };
    })
  ];
}
