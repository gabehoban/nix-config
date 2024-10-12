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
  networking.hostName = "casio";

  syscfg = {
    profiles.base = true;
    profiles.server = true;

    security.harden = true;

    tailscale = {
      enable = false;
    };
  };

  system.stateVersion = "24.05";
  nixpkgs.hostPlatform = "aarch64-linux";
}
