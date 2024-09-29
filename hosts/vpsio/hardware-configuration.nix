{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disks.nix
  ];

  boot = {
    initrd.availableKernelModules = [
      # "Normal" disk Support
      "sd_mod"
      "sr_mod"
      "nvme"
      "ahci"

      # QEMU
      "virtio_pci"
      "virtio_blk"
      "virtio_scsi"
      "virtio_net"

      # Hetzner Specific
      "ata_piix"
      "kvm-intel"
    ];
    growPartition = true;
    loader.grub.devices = lib.mkDefault [ "/dev/sda" ];
    loader.grub.configurationLimit = lib.mkDefault 3;
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
    firewall.allowPing = true;
    firewall.logRefusedConnections = lib.mkDefault false;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
