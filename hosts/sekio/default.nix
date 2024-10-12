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
    profiles.base = true;
    profiles.server = true;

    security.harden = true;

    tailscale = {
      enable = false;
    };
  };

  nixpkgs = {
    hostPlatform = "aarch64-linux";
    overlays = [
      (_final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
      (_self: super: {
        ubootRaspberryPi4_64bit = super.ubootRaspberryPi4_64bit.overrideAttrs (_oldAttrs: {
          extraConfig = ''
            CONFIG_AUTOBOOT_DELAY_STR="dfg\0"
            CONFIG_AUTOBOOT_KEYED=y
            CONFIG_AUTOBOOT_PROMPT="NO UART\0"
            CONFIG_AUTOBOOT_STOP_STR="1234\0"
            CONFIG_BOOTDELAY=-2
            CONFIG_SILENT_CONSOLE_UPDATE_ON_SET=y
            CONFIG_SILENT_CONSOLE=y
            CONFIG_SILENT_U_BOOT_ONLY=y
            CONFIG_SYS_DEVICE_NULLDEV=y
          '';
        });
      })
    ];
  };

  system.stateVersion = "24.05";
}
