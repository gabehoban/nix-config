{ pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      userName = "Gabe Hoban";
      userEmail = "gabehoban@icloud.com";

      ignores = [
        ".direnv"
        "result"
      ];

      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        push.autoSetupRemote = true;
      };

      lfs = {
        enable = true;
      };

      signing = {
        key = "3EADE0CB32D1BC80DF96F538AFD8F294983C4F95";
        signByDefault = false;
      };
    };
    gh = {
      enable = true;
      settings = {
        editor = "nvim";
        prompt = "enabled";
      };
      extensions = with pkgs; [
        gh-markdown-preview
        gh-dash
      ];
    };
  };
}
