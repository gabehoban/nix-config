{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin.steamcompattool ];
  };
  hardware.steam-hardware.enable = true;
}
