# https://discourse.nixos.org/t/rpi-zero-2w-in-prusa-3d-printer-aka-data-received-via-uart-over-gpio-disturbs-the-boot-process/36133/16
{
  config,
  pkgs,
  vars,
  self,
  inputs,
  lib,
  modulesPath,
  ...
}:
let
  blCfg = config.boot.loader;
  dtCfg = config.hardware.deviceTree;
  cfg = blCfg.generic-extlinux-compatible;
  timeoutStr = if blCfg.timeout == null then "-1" else toString blCfg.timeout;
  builderScript =
    <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.sh>;
  fixedBuilderScriptName = "extlinux-conf-builder-no-interaction.sh";
  fixedBuilderScript = pkgs.runCommand fixedBuilderScriptName { } ''
    (
    set -x
    ${pkgs.perl}/bin/perl -pe 's/^((?:TIMEOUT|MENU TITLE).*)$/# $1 # commented to ignore UART input during boot/g' ${builderScript} > $out
    )
  '';
  mkFixedBuilder =
    { pkgs }:
    pkgs.substituteAll {
      src = fixedBuilderScript;
      isExecutable = true;
      path = [
        pkgs.coreutils
        pkgs.gnused
        pkgs.gnugrep
      ];
      inherit (pkgs) bash;
    };
  fixedBuilder = mkFixedBuilder { inherit pkgs; };
  fixedPopulateBuilder = mkFixedBuilder { pkgs = pkgs.buildPackages; };
  builderArgs =
    "-g ${toString cfg.configurationLimit} -t ${timeoutStr}"
    + lib.optionalString (dtCfg.name != null) " -n ${dtCfg.name}"
    + lib.optionalString (!cfg.useGenerationDeviceTree) " -r";
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    self.nixosModules.syscfgOS
  ];
  system.build.installBootLoader = lib.mkForce "${fixedBuilder} ${builderArgs} -c";
  sdImage.populateRootCommands = lib.mkForce ''
    mkdir -p ./files/boot
    ${fixedPopulateBuilder} ${builderArgs} -c ${config.system.build.toplevel} -d ./files/boot
  '';
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

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_rpi4;

  syscfg = {
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
