{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.eza = {
    enable = true;
    package = pkgs.eza;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    extraOptions = [
      "--group-directories-first"
      "--header"
    ];

    git = true;
    icons = true;
  };

  home.shellAliases = {
    tree = lib.mkForce "${lib.getExe config.programs.eza.package} --tree --icons=always";
  };
}
