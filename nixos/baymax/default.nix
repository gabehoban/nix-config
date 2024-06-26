{ config, inputs, lib, pkgs, platform, username, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ./persistence.nix
    ../_mixins/services/clamav.nix
    ../_mixins/services/filesync.nix
    ../_mixins/services/ollama.nix
  ];

  zramSwap.enable = true;

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "mode=755" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/boot";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/encrypted_root_pool-nix";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "compress-force=zstd" "noatime" ];
  };

  fileSystems."/persist" = {
    device = "/dev/mapper/encrypted_root_pool-persist";
    fsType = "btrfs";
    neededForBoot = true;
    options = [ "compress-force=zstd" "noatime" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/encrypted_root_pool-home";
    fsType = "btrfs";
    options = [ "compress-force=zstd" ];
  };

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-partlabel/games";
    fsType = "xfs";
  };

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "aesni_intel" "cryptd" ];
      luks.devices."encrypted_root".device = "/dev/disk/by-partlabel/root";
    };
    kernelModules = [ "kvm_intel" ];
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
    # Disable USB autosuspend on workstations
    kernelParams = [ "usbcore.autosuspend=-1" "nvidia-drm.modeset=1" ];
  };

  hardware = {
    nvidia = {
      package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.beta;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
      open = false;
    };
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
    btrfs.autoScrub.enable = true;
  };
}