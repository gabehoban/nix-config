{
  pkgs,
  vars,
  self,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    self.nixosModules.syscfgOS
  ];
  nixpkgs = {
    hostPlatform = "aarch64-linux";
    overlays = [
      (_final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
      (_self: super: {
        ubootRaspberryPi4_64bit = super.ubootRaspberryPi4_64bit.overrideAttrs (_oldAttrs: {
          extraConfig = ''
            CONFIG_BOOTDELAY=-2
            CONFIG_SILENT_CONSOLE=y
            CONFIG_SYS_DEVICE_NULLDEV=y
            CONFIG_SILENT_CONSOLE_UPDATE_ON_SET=y
            CONFIG_SILENT_U_BOOT_ONLY=y
            CONFIG_AUTOBOOT_KEYED=y
            CONFIG_AUTOBOOT_PROMPT="NO UART\0"
            CONFIG_AUTOBOOT_DELAY_STR="dfg\0"
            CONFIG_AUTOBOOT_STOP_STR="1234\0"
          '';
        });
      })
    ];
  };

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_rpi4;

  syscfg = {
    security.harden = true;
    profiles.base = true;
  };

  system.stateVersion = "24.05";

  networking = {
    firewall.enable = lib.mkForce false;
    hostName = "syscfgOS-rpi";
  };

  services.openssh.enable = true;
  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  users.motd = ''
    Welcome to the bootstrap system.
    Steps:
      1. Clone dotfiles
      2. Run nixos-generate-config, copy over hardware-configuration.nix.
      3. Configure your host.
      4. Rebuild.
  '';

  users.users.${vars.user} = {
    isNormalUser = true;
    hashedPassword = "$7$CU..../....rtH/ZQtOTGlDUQyQz69Ti1$kn5YDoADsxNipuP1QLxQ7vC8OY8WJdWd9RNuwRcZHC.";
    hashedPasswordFile = lib.mkForce null;
  };
}
