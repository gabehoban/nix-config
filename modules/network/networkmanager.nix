{ lib, ... }:
{
  networking.networkmanager = {
    enable = true;
    plugins = lib.mkForce [ ];
    dns = "systemd-resolved";
    unmanaged = [
      "interface-name:tailscale*"
      "interface-name:rndis*"
      "interface-name:docker*"
      "interface-name:virbr*"
      "interface-name:vboxnet*"
      "interface-name:waydroid*"
    ];
  };

  systemd.network.wait-online.enable = lib.mkForce false;
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
}
