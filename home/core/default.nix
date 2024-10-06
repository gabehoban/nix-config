{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./gpg.nix
    ./fastfetch.nix
    ./direnv.nix
    ./lazygit.nix
    ./starship.nix
    ./zsh.nix
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
