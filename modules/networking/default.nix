{
  imports = [
    ./tailscale.nix
    ./openssh.nix
    ./time.nix
  ];
  config = {
    environment.persistence."/persist" = {
      directories = [
        "/etc/NetworkManager/system-connections"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
    networking.extraHosts = ''
      5.161.231.127 headscale.labrats.cc
    '';
    systemd.services.NetworkManager-wait-online.enable = false;
    systemd.network.wait-online.enable = false;
  };
}
