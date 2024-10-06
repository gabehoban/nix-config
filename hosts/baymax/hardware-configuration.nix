{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disks.nix
  ];

  #boot.loader.systemd-boot.enable = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  services.fstrim.enable = true;
  networking.useDHCP = lib.mkDefault true;
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
