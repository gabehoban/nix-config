{
  pkgs,
  lib,
  options,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ../../modules/core
    ../../modules/server
    ../../modules/network
  ];

  environment = {
    systemPackages = map lib.lowPrio [
      pkgs.curl
      pkgs.dnsutils
      pkgs.gitMinimal
      pkgs.htop
      pkgs.jq
      pkgs.tmux
    ];
    variables.BROWSER = "echo";
    ldso32 = null;
    stub-ld.enable = lib.mkDefault false;
  };

  system.switch = {
    enable = lib.mkDefault false;
    enableNg = lib.mkDefault true;
  };

  documentation = {
    enable = lib.mkDefault false;
    info.enable = lib.mkDefault false;
    man.enable = lib.mkDefault false;
    nixos.enable = lib.mkDefault false;
  };

  xdg = {
    autostart.enable = lib.mkDefault false;
    icons.enable = lib.mkDefault false;
    mime.enable = lib.mkDefault false;
    sounds.enable = lib.mkDefault false;
  };

  fonts.fontconfig.enable = lib.mkDefault false;
  programs.command-not-found.enable = lib.mkDefault false;

  programs.vim =
    {
      defaultEditor = lib.mkDefault true;
    }
    // lib.optionalAttrs (options.programs.vim ? enable) {
      enable = lib.mkDefault true;
    };

  # Delegate the hostname setting to dhcp/cloud-init by default
  networking.hostName = lib.mkOverride 1337 ""; # lower prio than lib.mkDefault

  # Enable SSH everywhere
  services.openssh.enable = true;

  # UTC everywhere!
  time.timeZone = lib.mkDefault "UTC";

  # No mutable users by default
  users.mutableUsers = false;

  systemd = {
    enableEmergencyMode = false;
    watchdog = {
      runtimeTime = "20s";
      rebootTime = "30s";
    };

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };

  virtualisation.vmVariant.virtualisation.graphics = lib.mkDefault false;
}
