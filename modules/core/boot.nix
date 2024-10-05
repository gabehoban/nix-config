{ lib, pkgs, ... }:
{
  boot = {
    # kernel console loglevel
    consoleLogLevel = 3;

    loader = {
      timeout = lib.mkForce 4;
      generationsDir.copyKernels = true;
      efi.canTouchEfiVariables = true;
    };

    # initrd and kernel tweaks
    initrd = {
      # Verbosity of the initrd
      verbose = false;

      systemd = {
        enable = true;
        strip = true;
        tpm2.enable = true;
      };

      # the set of kernel modules in the initial ramdisk used during the boot process
      availableKernelModules = [
        "ata_piix"
        "dm_mod"
        "ehci_pci"
        "rtsx_pci_sdmmc"
        "rtsx_usb_sdmmc"
        "sd_mod"
        "sr_mod"
        "usb_storage"
        "usbhid"
        "virtio_pci"
        "virtio_scsi"
      ];
    };

    # https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
    kernelParams = [
      "fbcon=nodefer"
      "idle=nomwait"
      "integrity_audit=1"
      "iommu=pt"
      "lsm=landlock,lockdown,yama,integrity,apparmor,bpf,tomoyo,selinux"
      "nohibernate"
      "noresume"
      "oops=panic"
      "page_alloc.shuffle=1"
      "page_poison=on"
      "pti=auto"
      "randomize_kstack_offset=on"
      "rootflags=noatime"
      "slab_nomerge"
    ];

    kernel.sysctl = {
      "dev.tty.ldisc_autoload" = 0;
      "fs.protected_fifos" = 2;
      "fs.protected_hardlinks" = 1;
      "fs.protected_regular" = 2;
      "fs.protected_symlinks" = 1;
      "fs.suid_dumpable" = 0;
      "kernel.dmesg_restrict" = 1;
      "kernel.ftrace_enabled" = false;
      "kernel.kexec_load_disabled" = true;
      "kernel.kptr_restrict" = 2;
      "kernel.perf_event_paranoid" = 3;
      "kernel.printk" = "3 3 3 3";
      "kernel.sysrq" = 0;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      "net.ipv4.tcp_rfc1337" = 1;
      "vm.mmap_min_addr" = 65536;
      "vm.mmap_rnd_bits" = 32;

      ## TCP optimization
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
      "net.core.optmem_max" = 65536;
      "net.core.rmem_default" = 1048576;
      "net.core.rmem_max" = 16777216;
      "net.core.somaxconn" = 8192;
      "net.core.wmem_default" = 1048576;
      "net.core.wmem_max" = 16777216;
      "net.ipv4.ip_local_port_range" = "16384 65535";
      "net.ipv4.tcp_max_syn_backlog" = 8192;
      "net.ipv4.tcp_max_tw_buckets" = 2000000;
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.ipv4.tcp_rmem" = "4096 1048576 2097152";
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";
      "net.ipv4.udp_rmem_min" = 8192;
      "net.ipv4.udp_wmem_min" = 8192;
    };
    blacklistedKernelModules = lib.concatLists [
      # Obscure network protocols
      [
        "dccp" # Datagram Congestion Control Protocol
        "sctp" # Stream Control Transmission Protocol
        "rds" # Reliable Datagram Sockets
        "tipc" # Transparent Inter-Process Communication
        "n-hdlc" # High-level Data Link Control
        "netrom" # NetRom
        "x25" # X.25
        "ax25" # Amateur X.25
        "rose" # ROSE
        "decnet" # DECnet
        "econet" # Econet
        "af_802154" # IEEE 802.15.4
        "ipx" # Internetwork Packet Exchange
        "appletalk" # Appletalk
        "psnap" # SubnetworkAccess Protocol
        "p8022" # IEEE 802.3
        "p8023" # Novell raw IEEE 802.3
        "can" # Controller Area Network
        "atm" # ATM
      ]

      # Old or rare or insufficiently audited filesystems
      [
        "adfs" # Active Directory Federation Services
        "affs" # Amiga Fast File System
        "befs" # "Be File System"
        "bfs" # BFS, used by SCO UnixWare OS for the /stand slice
        "cifs" # Common Internet File System
        "cramfs" # compressed ROM/RAM file system
        "efs" # Extent File System
        "erofs" # Enhanced Read-Only File System
        "exofs" # EXtended Object File System
        "freevxfs" # Veritas filesystem driver
        "f2fs" # Flash-Friendly File System
        "vivid" # Virtual Video Test Driver (unnecessary, and a historical cause of escalation issues)
        "gfs2" # Global File System 2
        "hpfs" # High Performance File System (used by OS/2)
        "hfs" # Hierarchical File System (Macintosh)
        "hfsplus" # " same as above, but with extended attributes
        "jffs2" # Journalling Flash File System (v2)
        "jfs" # Journaled File System - only useful for VMWare sessions
        "ksmbd" # SMB3 Kernel Server
        "minix" # minix fs - used by the minix OS
        "nfsv3" # " (v3)
        "nfsv4" # Network File System (v4)
        "nfs" # Network File System
        "nilfs2" # New Implementation of a Log-structured File System
        "omfs" # Optimized MPEG Filesystem
        "qnx4" # extent-based file system used by the QNX4 and QNX6 OSes
        "qnx6" # "
        "sysv" # implements all of Xenix FS, SystemV/386 FS and Coherent FS.
        "udf" # https://docs.kernel.org/5.15/filesystems/udf.html
      ]

      # Disable Thunderbolt and FireWire to prevent DMA attacks
      [
        "thunderbolt"
        "firewire-core"
      ]
      # All devices are wired... disable wifi modules
      [
        "iwlwifi"
      ]
    ];
  };
}
