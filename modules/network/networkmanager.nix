{ lib, ... }:
{
  networking.networkmanager = {
    enable = true;
  };
  # Make sure firewall is enabled
  networking.firewall.enable = true;

  systemd.network.wait-online.enable = lib.mkForce false;
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
}
