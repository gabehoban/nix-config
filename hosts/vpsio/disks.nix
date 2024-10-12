_: {
  # For impermanence
  boot.initrd.systemd.services.rollback = {
    description = "Rollback BTRFS root subvolume to a pristine state";
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    wantedBy = [ "initrd.target" ];
    before = [ "sysroot.mount" ];

    script = ''
      vgchange -ay pool
      mkdir -p /btrfs_tmp
      mount /dev/pool/root /btrfs_tmp

      if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';
  };

  environment.persistence."/persist".hideMounts = true;

  fileSystems = {
    "/persist" = {
      neededForBoot = true;
    };
  };

  disko.devices = {
    disk = {
      disk0 = {
        type = "disk";
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_52633424";

        content = {
          type = "gpt";

          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
            };

            main = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      pool = {
        type = "lvm_vg";

        lvs = {
          root = {
            size = "100%FREE";

            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];

              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                };

                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = [
                    "compress=zstd"
                    "subvol=persist"
                    "noatime"
                  ];
                };

                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "subvol=nix"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
