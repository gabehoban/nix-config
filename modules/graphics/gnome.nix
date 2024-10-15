{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
let
  cfg = config.syscfg.graphics;
in
{
  options.syscfg.graphics = {
    gnome = lib.mkEnableOption "GNOME desktop environment";
  };

  config = lib.mkIf cfg.gnome {
    services.xserver.desktopManager.gnome.enable = true;
    services.gnome.gnome-online-accounts.enable = false;

    # Exclude some packages we don't want
    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        EGL_PLATFORM = "wayland";
        XDG_SESSION_TYPE = "wayland";
      };
      systemPackages = with pkgs; [ dconf-editor ];
      gnome.excludePackages = with pkgs; [
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
    };

    home-manager.users."${vars.user}" =
      { lib, ... }:
      let
        inherit (lib.hm.gvariant) mkTuple;
      in
      {
        # dconf (gsettings) for Gnome applications
        dconf.settings = {
          "org/gnome/shell" = {
            favorite-apps = [
              "firefox.desktop"
              "org.gnome.Console.desktop"
              "org.gnome.Nautilus.desktop"
            ];
            welcome-dialog-last-shown-version = "9999";
          };
          "org/gnome/desktop/privacy" = {
            remember-app-usage = false;
            remember-recent-files = true;
          };
          "org/gnome/desktop/search-providers" = {
            disable-external = true;
          };
          "org/gnome/desktop/interface" = {
            clock-format = "12h";
            show-battery-percentage = true;
            clock-show-weekday = true;
            color-scheme = "prefer-dark";
            document-font-name = "Merriweather 11";
            font-name = "IBM Plex Sans 11";
            monospace-font-name = "JetBrainsMono Nerd Font 13";
          };
          "org/gnome/desktop/background" = {
            picture-uri = "file://${./wallpaper.png}";
            picture-uri-dark = "file://${./wallpaper.png}";
            picture-options = "zoom";
            primary-color = "#134dae";
            secondary-color = "#134dae";
            show-desktop-icons = false;
          };
          "org/gnome/calendar".show-weekdate = true;
          "org/gnome/desktop/sound" = {
            allow-volume-above-100-percent = true;
          };
          "org/gnome/desktop/wm/preferences" = {
            # Add minimise button, use Inter font
            button-layout = "appmenu:minimize,close";
            titlebar-font = "Inter Semi-Bold 11";
          };
          "org/gnome/desktop/input-sources" = {
            # Add three keyboad layouts (en, ar, fi)
            sources = [
              (mkTuple [
                "xkb"
                "us"
              ])
            ];
          };
          "org/gnome/desktop/media-handling" = {
            # Don't mount devices when plugged in
            automount = false;
            automount-open = false;
            autorun-never = true;
          };
        };
      };
  };
}
