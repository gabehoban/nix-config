{ user, pkgs, ... }:
{
  imports = [
    ../../core
    ../../desktop/alacritty.nix
    ../../desktop/mpv.nix
  ];
  home = {
    username = "${user}";
    homeDirectory = "/Users/${user}";
    stateVersion = "24.05";
    packages = with pkgs; [
      _1password
    ];
    # remove message when entering terminal if macos
    file.".hushlogin" = {
      enable = true;
      text = "";
    };
  };
}
