{ lib, pkgs, ... }:
{
  programs.fzf = {
    enable = true;

    defaultCommand = "${lib.getExe pkgs.fd} --type=f --hidden --exclude=.git";
    defaultOptions = [
      "--layout=reverse" # Top-first.
      "--exact" # Substring matching by default, `'`-quote for subsequence matching.
      "--bind=alt-p:toggle-preview,alt-a:select-all"
      "--multi"
      "--no-mouse"
      "--info=inline"

      # Style and widget layout
      "--ansi"
      "--with-nth=1.."
      "--header-first"
      "--border=rounded"
    ];

    enableBashIntegration = true;
    enableZshIntegration = false;

    tmux = {
      enableShellIntegration = true;
    };
  };
}
