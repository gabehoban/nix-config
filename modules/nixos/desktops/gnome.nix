{ pkgs, ... }:
{
  imports = [
    ./programs/_1password
    ./programs/firefox
    ./programs/steam
  ];

  # Enable Gnome
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };

  programs.dconf.enable = true;

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gnome-text-editor # text editor
      gnome-console
    ])
    ++ (with pkgs.gnome; [
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
    ]);

  environment.systemPackages =
    (with pkgs; [
      zafiro-icons
      dconf2nix
    ])
    ++ (with pkgs.gnome; [
      gnome-tweaks
      gnome-screenshot
    ]);

}
