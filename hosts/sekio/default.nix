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
  networking.hostName = "sekio";

  syscfg = {
    autoupgrade.enable = true;
    profiles.base = true;

    server = {
      blocky = true;
      grafana = true;
      prometheus = true;
      nginx = true;
      oauth2 = true;
    };

    stratum_1.enable = true;
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
