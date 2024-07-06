{ pkgs, ... }:
{
  # Enable GNOME
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  services.gnome.gnome-browser-connector.enable = true;
  environment.gnome.excludePackages = with pkgs; [
    gnome-connections
    gnome-tour
    baobab # disk usage
    epiphany # browser
    geary # email client
    gnome-calendar
    yelp # help
  ];

  # Prevent poorly auto-discovered ghost printers
  systemd.services.cups-browsed.enable = false;

  environment.systemPackages = with pkgs; [
    (pkgs.discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    mako
    gnome.gnome-tweaks
    gnome-extension-manager
  ];
}
