{ pkgs, ... }:
{
  home.packages = with pkgs.gnomeExtensions; [
    dash-to-dock
    dash-to-panel
    vitals
    user-themes
    tray-icons-reloaded
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "firefox.desktop"
        "Alacritty.desktop"
        "code.desktop"
        "steam.desktop"
      ];
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "dash-to-dock@micxgx.gmail.com"
        "trayIconsReloaded@selfmade.pl"
        "Vitals@CoreCoding.com"
      ];
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file:///home/gabehoban/nix-config/wallpapers/wallpaper.png";
      picture-uri-dark = "file:///home/gabehoban/nix-config/wallpapers/wallpaper.png";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-fixed = true;
      dock-position = "BOTTOM";
      running-indicator-style = "DOTS";
    };

    "org/gnome/mutter" = {
      edge-tiling = true;
    };

    "org/gnome/desktop/interface" = {
      clock-show-weekday = true;
      clock-show-seconds = true;
    };

    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      multi-monitor = true;
    };
  };
}
