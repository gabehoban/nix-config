{ user, ... }:
{
  imports = [
    ../../core
    ../../desktop/alacritty.nix
    ../../desktop/mpv.nix
    ../../desktop/vscode.nix
    ../../desktop/xdg.nix
    ../../desktop/zathura.nix
    ../../wayland
    ../../theme
  ];
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "24.05";
    extraOutputsToInstall = [
      "doc"
      "devdoc"
    ];
  };
}
