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
            CONFIG_AUTOBOOT=y
            CONFIG_AUTOBOOT_KEYED=y
            CONFIG_AUTOBOOT_STOP_STR="\x0b"
            CONFIG_AUTOBOOT_KEYED_CTRLC=y
            CONFIG_AUTOBOOT_PROMPT="autoboot in 1 second (hold 'CTRL^C' to abort)\n"
            CONFIG_BOOT_RETRY_TIME=15
            CONFIG_RESET_TO_RETRY=y
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
