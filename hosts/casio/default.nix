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

    server.blocky = true;

    stratum.enable = true;
    tailscale.enable = true;
  };

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  nixpkgs = {
    hostPlatform = "aarch64-linux";
    overlays = [
      (_final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
      (_self: super: {
        ubootRaspberryPi4_64bit = super.ubootRaspberryPi4_64bit.overrideAttrs (_oldAttrs: {
          extraConfig = ''
            CONFIG_AUTOBOOT=y
            CONFIG_BOOTDELAY=-2
          '';
        });
      })
    ];
  };

  system.stateVersion = "24.05";
}