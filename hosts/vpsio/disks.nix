{
  inputs,
  ...
}:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      disk0 = {
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_52633424";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
