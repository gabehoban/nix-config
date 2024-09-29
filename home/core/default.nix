{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./gpg.nix
    ./fastfetch.nix
    ./fish.nix
    ./direnv.nix
    ./lazygit.nix
    ./zellij.nix
  ];

  home.packages = with pkgs; [
    dconf
    bat
    btop
    xdg-utils
    eza
    ncdu
    ripgrep
    rclone
    fd
    fzf
  ];
}
