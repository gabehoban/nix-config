{ pkgs, ... }:
{
  programs = {
    nix-index-database.comma.enable = true;

    nix-index = {
      enable = true;
      package = pkgs.nix-index;

      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}
