{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./fail2ban.nix
  ];

  config = {
    networking.firewall = {
      enable = true;
      package = pkgs.iptables-nftables-compat;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      allowPing = true;
      logReversePathDrops = true;
      logRefusedConnections = false;
      checkReversePath = lib.mkForce false;
    };
  };
}
