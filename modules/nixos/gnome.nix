{ pkgs, ... }:
{
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';
  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      EGL_PLATFORM = "wayland";
      XDG_SESSION_TYPE = "wayland";
    };

    systemPackages = with pkgs; [
      grimblast
      wl-clipboard
      wlr-randr
      xorg.xeyes
      xorg.xrandr
      xclip
      zafiro-icons
      dconf2nix
      gnome-tweaks
      gnome-screenshot
    ];
  };

  programs.dconf.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    gnome-text-editor
    gnome-console
    cheese
    gnome-music
    epiphany
    geary
    evince
    gnome-characters
    totem
    tali
    iagno
    hitori
    atomix
  ];
}
