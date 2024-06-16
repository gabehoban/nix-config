{ config, desktop, hostname, inputs, lib, outputs, pkgs, stateVersion, username, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  isWorkstation = if (desktop != null) then true else false;
in
{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    ./_mixins/applications
  ]
  ++ lib.optional (builtins.pathExists (./. + "/_mixins/users/${username}")) ./_mixins/users/${username}
  ++ lib.optional (builtins.pathExists (./. + "/_mixins/hosts/${hostname}")) ./_mixins/hosts/${hostname}
  ++ lib.optional (isWorkstation) ./_mixins/desktop;

  home = {
    inherit stateVersion;
    inherit username;
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";

    file = {
      "${config.xdg.configHome}/fastfetch/config.jsonc".text = builtins.readFile ./_mixins/configs/fastfetch.jsonc;
    };
    file = {
      "${config.xdg.configHome}/halloy/themes/harmony-dark.yaml".text = builtins.readFile ./_mixins/configs/harmony-dark.yaml;
    };
    file = {
      "${config.xdg.configHome}/fish/functions/build-home.fish".text = builtins.readFile ./_mixins/configs/build-home.fish;
    };
    file = {
      "${config.xdg.configHome}/fish/functions/switch-home.fish".text = builtins.readFile ./_mixins/configs/switch-home.fish;
    };
    file = {
      "${config.xdg.configHome}/fish/functions/help.fish".text = builtins.readFile ./_mixins/configs/help.fish;
    };
    file = {
      "${config.xdg.configHome}/fish/functions/h.fish".text = builtins.readFile ./_mixins/configs/h.fish;
    };
    file = {
      "${config.xdg.configHome}/fish/functions/gpg-restore.fish".text = builtins.readFile ./_mixins/configs/gpg-restore.fish;
    };
    file = {
      "${config.xdg.configHome}/fish/functions/get-nix-hash.fish".text = builtins.readFile ./_mixins/configs/get-nix-hash.fish;
    };

    # A Modern Unix experience
    packages = with pkgs; [
      asciinema-agg # Convert asciinema to .gif
      asciinema # Terminal recorder
      bandwhich # Modern Unix `iftop`
      bmon # Modern Unix `iftop`
      chroma # Code syntax highlighter
      clinfo # Terminal OpenCL info
      croc # Terminal file transfer
      curlie # Terminal HTTP client
      dconf2nix # Nix code from Dconf files
      difftastic # Modern Unix `diff`
      dogdns # Modern Unix `dig`
      dotacat # Modern Unix lolcat
      dua # Modern Unix `du`
      duf # Modern Unix `df`
      du-dust # Modern Unix `du`
      editorconfig-core-c # EditorConfig Core
      entr # Modern Unix `watch`
      fastfetch # Modern Unix system info
      fd # Modern Unix `find`
      frogmouth # Terminal mardown viewer
      glow # Terminal Markdown renderer
      gping # Modern Unix `ping`
      h # Modern Unix autojump for git projects
      hexyl # Modern Unix `hexedit`
      httpie # Terminal HTTP client
      iperf3 # Terminal network benchmarking
      jiq # Modern Unix `jq`
      mdp # Terminal Markdown presenter
      mtr # Modern Unix `traceroute`
      netdiscover # Modern Unix `arp`
      nixpkgs-review # Nix code review
      nix-prefetch-scripts # Nix code fetcher
      nurl # Nix URL fetcher
      nyancat # Terminal rainbow spewing feline
      onefetch # Terminal git project info
      optipng # Terminal PNG optimizer
      procs # Modern Unix `ps`
      quilt # Terminal patch manager
      rclone # Modern Unix `rsync`
      rsync # Traditional `rsync`
      sd # Modern Unix `sed`
      speedtest-go # Terminal speedtest.net
      tldr # Modern Unix `man`
      ueberzugpp # Terminal image viewer integration
      unzip # Terminal ZIP extractor
      upterm # Terminal sharing
      wget # Terminal HTTP client
      wget2 # Terminal HTTP client
      yq-go # Terminal `jq` for YAML
    ] ++ lib.optionals isLinux [
      figlet # Terminal ASCII banners
      lurk # Modern Unix `strace`
      pciutils # Terminal PCI info
      psmisc # Traditional `ps`
      ramfetch # Terminal system info
      snapcraft
      usbutils # Terminal USB info
      writedisk # Modern Unix `dd`
    ] ++ lib.optionals isDarwin [
      m-cli # Terminal Swiss Army Knife for macOS
      nh
      coreutils
    ];
    sessionVariables = {
      EDITOR = "micro";
      MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
      MANROFFOPT = "-c";
      PAGER = "bat";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };
  };

  fonts.fontconfig.enable = true;

  # Workaround home-manager bug with flakes
  news.display = "silent";

  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    package = pkgs.unstable.nix;
    gc = {
      automatic = true;
      options = "--delete-older-than +3";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-substituters = [
        "https://gabehoban.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "gabehoban.cachix.org-1:BIoL9Y7AtTdEBgEUW0iMg49k0iHBlzFr/lMGtp+6K9U="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = false;
    };
  };

  programs = {
    gpg = {
      enable = true;
      scdaemonSettings = {
        disable-ccid = true;
      };
      publicKeys = [
        {
          source = ./_mixins/configs/publickey.gpg;
          trust = "ultimate";
        }
      ];
      mutableKeys = false;
      mutableTrust = true;
      settings = {
        default-key = "0xAFD8F294983C4F95";
        trusted-key = "0xAFD8F294983C4F95";
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        charset = "utf-8";
        no-comments = "";
        no-emit-version = "";
        no-greeting = "";
        keyid-format = "0xlong";
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";
        with-fingerprint = "";
        require-cross-certification = "";
        no-symkey-cache = "";
        use-agent = "";
      };
    };
    home-manager.enable = true;
    info.enable = true;
    jq.enable = true;
    micro = {
      enable = true;
      settings = {
        autosu = true;
        colorscheme = "simple";
        diffgutter = true;
        paste = true;
        rmtrailingws = true;
        savecursor = true;
        saveundo = true;
        scrollbar = true;
        scrollbarchar = "•";
        scrollmargin = 4;
        scrollspeed = 1;
      };
    };
    nix-index.enable = true;
    ripgrep = {
      arguments = [
        "--colors=line:style:bold"
        "--max-columns-preview"
        "--smart-case"
      ];
      enable = true;
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      # Replace cd with z and add cdi to access zi
      options = [
        "--cmd cd"
      ];
    };
        # Bat Pager
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batgrep
        batwatch
        prettybat
      ];
      config = {
        style = "plain";
      };
    };
    dircolors = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
    eza = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
      git = true;
      icons = true;
    };
  };

  services = {
    gpg-agent = {
      enable = isLinux;
      enableScDaemon = true;
      enableSshSupport = true;
      defaultCacheTtl = 34560000;
      maxCacheTtl = 34560000;
      pinentryPackage = pkgs.pinentry-curses;
    };
  };
  systemd.user.startServices = lib.mkIf isLinux "sd-switch";

  xdg = {
    enable = isLinux;
    userDirs = {
      enable = isLinux;
      createDirectories = lib.mkDefault true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
      };
    };
    mimeApps = {
      enable                              =  true;
      defaultApplications = {
          "default-web-browser"           = [ "firefox.desktop" ];
          "text/html"                     = [ "firefox.desktop" ];
          "x-scheme-handler/http"         = [ "firefox.desktop" ];
          "x-scheme-handler/https"        = [ "firefox.desktop" ];
          "x-scheme-handler/about"        = [ "firefox.desktop" ];
          "x-scheme-handler/unknown"      = [ "firefox.desktop" ];
      };
    };
  };
}