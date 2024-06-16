{ inputs, lib, pkgs, ...}: {
  programs.git = {
    enable = true;
    aliases = {
      ci = "commit";
      cl = "clone";
      co = "checkout";
      purr = "pull --rebase";
      dlog = "!f() { GIT_EXTERNAL_DIFF=difft git log -p --ext-diff $@; }; f";
      dshow = "!f() { GIT_EXTERNAL_DIFF=difft git show --ext-diff $@; }; f";
      graph  = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };
    difftastic = {
      display = "side-by-side-show-both";
      enable = true;
    };
    extraConfig = {
      advice = {
        statusHints = false;
      };
      color = {
        branch = false;
        diff = false;
        interactive = true;
        log = false;
        status = true;
        ui = false;
      };
      core = {
        pager = "bat";
      };
      push = {
        default = "matching";
      };
      pull = {
        rebase = false;
      };
      init = {
        defaultBranch = "main";
      };
    };
    ignores = [
      "*.log"
      "*.out"
      ".DS_Store"
      "bin/"
      "dist/"
      "result"
    ];
  };
}