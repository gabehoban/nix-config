{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
let
  cfg = config.syscfg.profiles;
in
{
  options.syscfg.profiles.base = lib.mkOption {
    description = "syscfgOS minimal base for all systems";
    type = lib.types.bool;
    default = pkgs.stdenv.isLinux;
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.base {
      environment = {
        systemPackages =
          (with pkgs; [
            # shell related
            zsh
            zsh-autosuggestions
            zsh-nix-shell

            # utilities
            wget
            htop
            rsync
            bc
            units
            sops

            # packages that must come with every Linux system
            curl
            lsof
            xz
            zip
            pstree
            lz4
            unzip
            tree
            fd
            acpi
            usbutils
            pciutils
            killall
            file
            dig
            pv
            smartmontools

            # Other productivity
            yt-dlp
            strace
            netcat
            nmap
            pwgen
            gping
            traceroute
            gnupatch
            ripgrep
            tmux
            lf
            jq # json query
            ouch # compression
            hexyl # hex viewer

            # Crisis tools https://www.brendangregg.com/blog/2024-03-24/linux-crisis-tools.html
            sysstat
            tcpdump
            trace-cmd
            ethtool
            numactl
          ])
          ++ lib.optionals pkgs.stdenv.isx86_64 [
            # x86_64 specific tools
            pkgs.cpuid
            pkgs.msr-tools
            pkgs.tiptop
          ];
        shells = [ pkgs.zsh ];
        variables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
          BROWSER = lib.mkDefault "echo";

          # clean up
          GTK2_RC_FILES = "$XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0";
          LESSHISTFILE = "-";
          SQLITE_HISTORY = "/tmp/sqlite_history";
          WGETRC = "$XDG_CONFIG_HOME/wget/wgetrc";
          TMUX_TMPDIR = "$XDG_RUNTIME_DIR";
          GOPATH = "$HOME/repos/go";
          HISTFILE = "$XDG_DATA_HOME/history";

          LC_ALL = "en_US.UTF-8";
          DO_NOT_TRACK = "1";

          # Java issue fix
          _JAVA_AWT_WM_NONREPARENTING = "1";
        };
      };

      security.sudo.extraConfig = ''
        Defaults lecture = never
      '';

      home-manager.users."${vars.user}" = {
        programs = {
          ssh = {
            enable = true;
            addKeysToAgent = "yes";
          };
          tmux = {
            enable = true;

            plugins = with pkgs.tmuxPlugins; [
              sensible
              resurrect
              copycat
              continuum
              tmux-thumbs
            ];
            clock24 = false;
          };
          lf = {
            enable = true;
            extraConfig = "set shell sh";
            commands = {
              open = ''
                  ''${{
                case $(file --mime-type "$(readlink -f $f)" -b) in
                  text/*|application/json|inode/x-empty) $EDITOR $fx ;;
                  application/*) nvim $fx ;;
                  *) for f in $fx; do setsid $OPENER $f > /dev/null 2> /dev/null & done ;;
                esac
                }}
              '';
            };
            cmdKeybindings = {
              "<enter>" = "open";
            };
          };
        };

        services.ssh-agent.enable = true;

        xdg = {
          enable = true;
          mimeApps.enable = true;
          userDirs = {
            enable = true;
            createDirectories = false;
            desktop = "$HOME/desktop";
            documents = "$HOME/documents";
            download = "$HOME/downloads";
            pictures = "$HOME/pictures";
            videos = "$HOME/pictures/videos";
            music = "";
            publicShare = "";
            templates = "";
          };
          configFile = {
            "user-dirs.locale".text = "en_US";

            # prevent home-manager from failing after rebuild
            "mimeapps.list".force = true;
            "user-dirs.locale".force = true;
            "user-dirs.dirs".force = true;
          };
        };
      };
    })
  ];
}
