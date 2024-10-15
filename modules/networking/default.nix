{
  imports = [
    ./tailscale.nix
    ./openssh.nix
    ./chrony.nix
  ];
  config = {
    networking.extraHosts = ''
      5.161.231.127 headscale.labrats.cc
    '';
    systemd.services.NetworkManager-wait-online.enable = false;
    systemd.network.wait-online.enable = false;
  };
}
