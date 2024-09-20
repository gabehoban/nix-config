{ config, lib, ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_500GB_S5H7NS1N512889D";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
              label = "boot";
            };
            ESP = {
              size = "512M";
              type = "EF00";
              label = "ESP";
              content = {
                extraArgs = [ "-n ESP" ];
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "encryptedRoot";
                settings = {
                  allowDiscards = true;
                  keyFile = "/tmp/secret.key";
                };
                additionalKeyFiles = [ "/dev/disk/by-id/usb-SMI_USB_DISK-0:0" ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" "-L ${config.networking.hostName}" ]; # Override existing partition
                  postCreateHook = /* sh */ ''
                      MNTPOINT=$(mktemp -d)
                      mount "/dev/disk/by-label/${config.networking.hostName}" "$MNTPOINT" -o subvol=/
                      trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
                      btrfs subvolume snapshot -r $MNTPOINT/root $MNTPOINT/root-blank
                    '';
                  subvolumes = {
                    "/root" = {
                      mountOptions = [ "compress=zstd" ];
                      mountpoint = "/";
                    };
                    "/persist" = {
                      mountOptions = [ "compress=zstd" ];
                      mountpoint = "/persist";
                    };
                    "/nix" = {
                      mountOptions = [ "compress=zstd" "noatime" ];
                      mountpoint = "/nix";
                    };
                    "/home" = {
                      mountOptions = [ "compress=zstd" "noatime" ];
                      mountpoint = "/home";
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap = {
                        swapfile.size = "32G";
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  }

