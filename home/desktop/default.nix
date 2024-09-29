{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./mpv.nix
    ./vscode.nix
    ./xdg.nix
    ./zathura.nix
  ];

  home.packages = with pkgs; [
    ffmpeg
    fractal
    libnotify
    mpd
    loupe
    nautilus
    obs-studio
    pavucontrol
    playerctl
    vesktop
  ];
}
