{
  self,
  pkgs,
  ...
}:
{
  imports = [
    self.nixosModules.syscfgOS
    (import ./hardware.nix)
    (import ./disk.nix)
    (import ./persist.nix)
  ];
  networking.hostName = "baymax";

  # My configuration specific settings
  syscfg = {
    autoupgrade.enable = true;

    profiles.base = true;

    graphics = {
      gnome = true;
      apps = true;
      nvidia = true;
    };

    development = {
      enable = true;
      emulation.systems = [
        "aarch64-linux"
      ];
    };

    security = {
      harden = true;
      yubikey = true;
    };

    tailscale = {
      enable = true;
    };
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "auto";
    };

    efi.canTouchEfiVariables = true;
  };

  sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  chaotic.scx.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.05";
}
