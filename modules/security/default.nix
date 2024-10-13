{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.syscfg.security;
  inherit (lib)
    mkOption
    types
    mkMerge
    mkIf
    mkEnableOption
    ;
in
{
  options.syscfg.security = {
    harden = mkOption {
      description = "Whether to harden the system";
      type = types.bool;
      default = pkgs.stdenv.isLinux;
    };
    yubikey = mkEnableOption "YubiKey support";
  };

  config = mkMerge [
    (mkIf cfg.yubikey {
      hardware.gpgSmartcards.enable = true;

      environment.systemPackages = with pkgs; [
        age
        age-plugin-yubikey
        gnupg
        libu2f-host
        yubico-piv-tool
        yubikey-manager
        yubikey-manager-qt
        yubikey-personalization
        yubikey-personalization-gui
        yubikey-touch-detector
        yubioath-flutter
      ];

      environment.shellInit = ''
        export GPG_TTY="$(tty)"
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        gpgconf --launch gpg-agent
        gpg-connect-agent updatestartuptty /bye > /dev/null
      '';

      programs.gnupg.agent = {
        enable = true;
        enableExtraSocket = true;
        enableSSHSupport = true;
        settings = {
          default-cache-ttl = 34560000;
          max-cache-ttl = 34560000;
        };
      };
      programs.ssh.startAgent = lib.mkForce false;

      services.pcscd.enable = true;
      services.udev.packages = [ pkgs.yubikey-personalization ];
      services.yubikey-agent.enable = true;
    })
    (mkIf cfg.harden {
      # Only enable firewall on non-VMs. VMs rely on host's firewall.
      networking.firewall.enable = true;

      services = {
        fail2ban = {
          enable = true;
          bantime = lib.mkDefault "10m";
          bantime-increment = {
            enable = lib.mkDefault true;
            factor = lib.mkDefault "1";
            maxtime = lib.mkDefault "3600h";
            multipliers = lib.mkDefault "1 2 4 8 16 32 64";
            rndtime = lib.mkDefault "8m";
          };
          daemonSettings = {
            Definition = {
              loglevel = lib.mkDefault "INFO";
              logtarget = "/var/log/fail2ban/fail2ban.log";
              socket = "/run/fail2ban/fail2ban.sock";
              pidfile = "/run/fail2ban/fail2ban.pid";
              dbfile = "/var/lib/fail2ban/fail2ban.sqlite3";
              dbpurageage = lib.mkDefault "1d";
            };
          };
          ignoreIP = [
            "127.0.0.1/8"
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/24"
          ];
          maxretry = lib.mkDefault 5;
        };
        logrotate.settings."/var/log/fail2ban/fail2ban.log" = { };

        endlessh-go = {
          enable = true;
          port = 22;
          prometheus = {
            enable = true;
            listenAddress = "127.0.0.1";
            port = 2112;
          };
          openFirewall = true;
        };
      };

      boot = {
        tmp.cleanOnBoot = true;

        kernelParams = [
          # Reduce boot TTY output
          "quiet"
          "vga=current"
        ];

        kernel.sysctl = {
          "fs.suid_dumpable" = 0;
          "kernel.dmesg_restrict" = 1;
          "kernel.sysrq" = 0;

          # Prevent bogus ICMP errors from filling logs
          "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

          # Ignore all ICMP redirects (breaks routers)
          "net.ipv4.conf.all.accept_redirects" = false;
          "net.ipv4.conf.all.secure_redirects" = false;
          "net.ipv4.conf.default.accept_redirects" = false;
          "net.ipv4.conf.default.secure_redirects" = false;
          "net.ipv6.conf.all.accept_redirects" = false;
          "net.ipv6.conf.default.accept_redirects" = false;

          # Prevent syn flood attack
          "net.ipv4.tcp_syncookies" = 1;
          "net.ipv4.tcp_synack_retries" = 5;

          # TIME-WAIT Assassination fix
          "net.ipv4.tcp_rfc1337" = 1;

          # Ignore outgoing ICMP redirects (IPv4 only)
          "net.ipv4.conf.all.send_redirects" = false;
          "net.ipv4.conf.default.send_redirects" = false;

          # Use TCP fast open to speed up some requests
          "net.ipv4.tcp_fastopen" = 3;

          # Enable "TCP Bottleneck Bandwidth and Round-Trip Time Algorithm"
          "net.inet.tcp.functions_default" = "bbr";
          # Use CAKE instead of CoDel
          "net.core.default_qdisc" = "cake";
        };

        kernelModules = [ "tcp_bbr" ];

        blacklistedKernelModules = [
          "adfs"
          "af_802154"
          "affs"
          "appletalk"
          "atm"
          "ax25"
          "befs"
          "bfs"
          "can"
          "cramfs"
          "dccp"
          "decnet"
          "econet"
          "efs"
          "erofs"
          "exofs"
          "f2fs"
          "freevxfs"
          "gfs2"
          "hfs"
          "hfsplus"
          "hpfs"
          "ipx"
          "jffs2"
          "jfs"
          "minix"
          "n-hdlc"
          "netrom"
          "nilfs2"
          "omfs"
          "p8022"
          "p8023"
          "psnap"
          "qnx4"
          "qnx6"
          "rds"
          "rose"
          "sctp"
          "sysv"
          "tipc"
          "udf"
          "ufs"
          "vivid"
          "x25"
          "firewire-core"
          "firewire-sbp2"
          "sbp2"
          "isdn"
          "arcnet"
          "phonet"
          "wimax"
          "floppy"

          # no beeping
          "snd_pcsp"
          "pcspkr"
        ];
      };

      security = {
        allowSimultaneousMultithreading = true;
        forcePageTableIsolation = true;
        lockKernelModules = false;
        polkit.enable = true;
        protectKernelImage = true;
        rtkit.enable = true;
        apparmor = {
          enable = true;
          packages = with pkgs; [
            apparmor-utils
            apparmor-profiles
          ];
        };
      };

      networking.stevenblack = {
        enable = true;
        block = [
          "fakenews"
          "gambling"
          "porn"
        ];
      };
    })
  ];
}
