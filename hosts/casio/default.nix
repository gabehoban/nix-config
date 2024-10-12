{
  config,
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
      enable = false;
    };
    profiles.server = true;
    security.harden = true;
  };

  networking = {
    hostName = "arkelli";

    firewall.enable = true;
    networkmanager.enable = false;
  };

  nixpkgs.hostPlatform = "aarch64-linux";
  system.stateVersion = "24.05";

  services.openssh.enable = true;
}
