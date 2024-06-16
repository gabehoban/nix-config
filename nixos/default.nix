{ config, desktop, hostname, inputs, lib, modulesPath, outputs, pkgs, platform, stateVersion, username, ... }:
let
  isInstall = if (builtins.substring 0 4 hostname != "iso-") then true else false;
  isWorkstation = if (desktop != null) then true else false;
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
  syncthing = {
    hosts = [
      "baymax"
    ];
    tcpPorts = [ 22000 ];
    udpPorts = [ 22000 21027 ];
  };
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.nix-index-database.nixosModules.nix-index

    (modulesPath + "/installer/scan/not-detected.nix")
    ./${hostname}
    ./_mixins/configs
    ./_mixins/users
  ] ++ lib.optional (isWorkstation) ./_mixins/desktop;

  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelModules = [ "vhost_vsock" ];
    kernelParams = [
      "boot.shell_on_fail"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = {
      "vm.page-cluster" = 1;
    };
    loader = lib.mkIf (isInstall) {
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 3;
      systemd-boot.consoleMode = "max";
      systemd-boot.enable = true;
      systemd-boot.memtest86.enable = true;
      timeout = 10;
    };
  };

  console = {
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
    keyMap = "us";
    packages = with pkgs; [ tamzen ];
  };

  i18n = {
    defaultLocale = "en_US.utf8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.utf8";
      LC_IDENTIFICATION = "en_US.utf8";
      LC_MEASUREMENT = "en_US.utf8";
      LC_MONETARY = "en_US.utf8";
      LC_NAME = "en_US.utf8";
      LC_NUMERIC = "en_US.utf8";
      LC_PAPER = "en_US.utf8";
      LC_TELEPHONE = "en_US.utf8";
      LC_TIME = "en_US.utf8";
    };
  };
  services.xserver.xkb.layout = "us";
  time.timeZone = "America/New_York";

  # Only install the docs I use
  documentation.enable = true;
  documentation.nixos.enable = false;
  documentation.man.enable = false;
  documentation.info.enable = false;
  documentation.doc.enable = false;

  environment = {
    defaultPackages = with pkgs; lib.mkForce [
      coreutils-full
      micro
    ];

    systemPackages = with pkgs; [
      git
      nix-output-monitor
    ] ++ lib.optionals (isInstall) [
      inputs.fh.packages.${platform}.default
      inputs.nixos-needtoreboot.packages.${platform}.default
      clinfo
      distrobox
      fuse-overlayfs
      libva-utils
      nvd
      nvme-cli
      smartmontools
      sops
      ssh-to-age
      xfsprogs
    ] ++ lib.optionals (isInstall && hasNvidia) [
      nvtopPackages.full
      vdpauinfo
    ];

    variables = {
      EDITOR = "micro";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };
  };

  # Use passed hostname to configure basic networking
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ]
        ++ lib.optionals (builtins.elem hostname syncthing.hosts) syncthing.tcpPorts;
      allowedUDPPorts = [ ]
        ++ lib.optionals (builtins.elem hostname syncthing.hosts) syncthing.udpPorts;
      trustedInterfaces = lib.mkIf (isInstall) [ "lxdbr0" ];
    };
    hostName = hostname;
    useDHCP = lib.mkDefault true;
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    optimise.automatic = true;
    package = lib.mkIf (isInstall) pkgs.unstable.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "${platform}";

  programs = {
    command-not-found.enable = false;
    dconf.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_cursor_default block blink
        set fish_cursor_insert line blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual block
        set -U fish_color_autosuggestion brblack
        set -U fish_color_cancel -r
        set -U fish_color_command green
        set -U fish_color_comment brblack
        set -U fish_color_cwd brgreen
        set -U fish_color_cwd_root brred
        set -U fish_color_end brmagenta
        set -U fish_color_error red
        set -U fish_color_escape brcyan
        set -U fish_color_history_current --bold
        set -U fish_color_host normal
        set -U fish_color_match --background=brblue
        set -U fish_color_normal normal
        set -U fish_color_operator cyan
        set -U fish_color_param blue
        set -U fish_color_quote yellow
        set -U fish_color_redirection magenta
        set -U fish_color_search_match bryellow '--background=brblack'
        set -U fish_color_selection white --bold '--background=brblack'
        set -U fish_color_status red
        set -U fish_color_user brwhite
        set -U fish_color_valid_path --underline
        set -U fish_pager_color_completion normal
        set -U fish_pager_color_description yellow
        set -U fish_pager_color_prefix white --bold --underline
        set -U fish_pager_color_progress brwhite '--background=cyan'
      '';
      shellAbbrs = lib.mkIf (isInstall) {
        captive-portal = "${pkgs.xdg-utils}/bin/xdg-open http://$(${pkgs.iproute2}/bin/ip --oneline route get 1.1.1.1 | ${pkgs.gawk}/bin/awk '{print $3}')";
      };
      shellAliases = {
        nano = "micro";
      };
    };
    mosh.enable = true;
    nano.enable = lib.mkDefault false;
    nh = {
      clean = {
        enable = true;
        extraArgs = "--keep-since 10d --keep 5";
      };
      enable = true;
      flake = "/home/${username}/nix-config";
    };
    nix-index-database.comma.enable = true;
    ssh.startAgent = true;
  };

  services = {
    hardware.bolt.enable = true;
    kmscon = {
      enable = true;
      hwRender = true;
      fonts = [{
        name = "FiraCode Nerd Font Mono";
        package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
      }];
      extraConfig = ''
        font-size=14
        xkb-layout=us
      '';
    };
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = lib.mkDefault "no";
      };
    };
    resolved.enable = true;
    sshguard = {
      enable = true;
      whitelist = [
        "10.0.0.0/8"
      ];
    };
  };

  # Disable hiberate and hybrid-sleep when using zram.
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  zramSwap = {
    algorithm = "lz4";
    enable = true;
  };

  systemd.tmpfiles.rules = [
    "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
  ];

  system = {
    nixos.label = lib.mkIf (isInstall) "-";
    stateVersion = stateVersion;
  };
}
