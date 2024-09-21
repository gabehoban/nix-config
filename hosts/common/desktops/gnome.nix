{ pkgs, ... }:
{

  # Enable Gnome
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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
    (with pkgs; [ zafiro-icons ])
    ++ (with pkgs.gnome; [
      gnome-tweaks
      gnome-screenshot
    ]);

}
