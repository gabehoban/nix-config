{
  self,
  inputs,
  ...
}:
{
  imports = [
    self.nixosModules.syscfgOS
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    (import ./hardware.nix)
  ];

  syscfg = {
    tailscale = {
      enable = true;
    };
    profiles.server = true;

    # TODO re-enable
    security.harden = false;
  };

  topology.self.interfaces.end0.network = "home";
  networking = {
    hostName = "argali";

    # TODO properly configure firewall rules
    firewall.enable = false;

    # TODO define connections as nm files
    networkmanager.enable = false;
  };

  nixpkgs.hostPlatform = "aarch64-linux";
  system.stateVersion = "23.11";

  services.openssh.enable = true;
}
