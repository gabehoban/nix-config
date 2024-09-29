{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.disko.nixosModules.disko ];

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  disko.devices = {
    disk = {
      disk0 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_500GB_S5H7NS1N512889D";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            rpool = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";
        options = {
          ashift = "12";
          cachefile = "none";
        };
        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          canmount = "off";
          compression = "zstd";
          dnodesize = "auto";
          normalization = "formD";
          xattr = "sa";
          mountpoint = "none";
        };
        datasets = {
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            mountOptions = [ "zfsutil" ];

            postCreateHook = ''
              zfs snapshot rpool/local/root@blank
            '';
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            mountOptions = [ "zfsutil" ];
          };
          "safe/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            mountOptions = [ "zfsutil" ];
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;

  boot.initrd.systemd.enable = lib.mkDefault true;
  boot.initrd.systemd.services.rollback = {
    description = "Rollback root filesystem to a pristine state on boot";
    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-rpool.service" ];
    before = [ "sysroot.mount" ];
    path = with pkgs; [ zfs ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      zfs rollback -r rpool/local/root@blank && echo "  >> >> rollback complete << <<"
    '';
  };

  fileSystems."/games" = {
    device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_232758800485_1-part1";
    fsType = "xfs";
    options = [
      "defaults"
      "discard"
      "noatime"
    ];
  };
}
