{ pkgs, config, ... }:
let
  # Assuming extensionUuid is unique to Gnome extensions
  extensions = builtins.filter (p: p ? "extensionUuid") config.home.packages;
in
{
  home.packages = with pkgs.gnomeExtensions; [
    appindicator
    arcmenu
    blur-my-shell
    caffeine
    dash-to-panel
    hibernate-status-button
    no-overview
    quick-settings-tweaker
    tiling-assistant
  ];

  # NixOS doesn't set a default cursor can cause issues
  home.pointerCursor = {
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 16;
    gtk.enable = true;
    x11.enable = true;
  };

  services.gpg-agent.pinentryPackage = pkgs.pinentry-gnome3;

  # gnome-keyring sets SSH_AUTH_SOCK which conflicts with gpg-agent
  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Hidden=true
  '';

  # Qt styling isn't controlled by Gnome or gnome-tweaks
  qt.enable = true;
  qt.platformTheme.name = "adwaita";
  qt.style = {
    package = pkgs.adwaita-qt;
    name = "adwaita-dark";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      clock-show-date = true;
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      gtk-theme = "Adwaita-dark";
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 3;
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      edge-tiling = false;
      overlay-key = "Super_L";
      workspaces-only-on-primary = true;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      search-view = "list-view";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      # Enable installed extensions by default
      enabled-extensions = map (e: e.extensionUuid) extensions;
    };
  };
}
