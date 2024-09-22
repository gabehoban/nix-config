{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    bfg-repo-cleaner
    git-crypt
    git-filter-repo
    git-lfs
    gitflow
    gitleaks
    gitlint
  ];

  programs = {
    git = {
      enable = true;
      package = pkgs.gitFull;

      userName = "Gabe Hoban";
      userEmail = "gabehoban@icloud.com";

      delta = {
        enable = true;

        options = {
          dark = true;
          features = lib.mkForce "decorations side-by-side navigate";
          line-numbers = true;
          navigate = true;
          side-by-side = true;
        };
      };

      extraConfig = {
        fetch = {
          prune = true;
        };

        init = {
          defaultBranch = "main";
        };

        pull = {
          rebase = true;
        };

        push = {
          autoSetupRemote = true;
          default = "current";
        };

        rebase = {
          autoStash = true;
        };
      };
    };
  };
}
