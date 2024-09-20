{
  inputs,
  lib,
  config,
  pkgs,
  outputs,
  ...
}:
{
  home = {
    persistence = {
      "/persist/home/gabehoban" = {
        directories = [
          "Documents"
          "Downloads"
          "Code"
          ".local/bin"
          ".local/share/nix"
          ".ssh"
          ".local"
          ".config"
          ".bash_history"
        ];
        allowOther = true;
      };
    };
  };
}
