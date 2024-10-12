{
  imports = [
    ./tailscale.nix
    ./headscale.nix
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
    systemd.services.NetworkManager-wait-online.enable = false;
    systemd.network.wait-online.enable = false;
  };
}
