{ pkgs, ... }:
let
  plugins = with pkgs.tmuxPlugins; [
    {
      plugin = resurrect;
      extraConfig = ''
        set -g @resurrect-strategy-vim 'session'
        set -g @resurrect-strategy-nvim 'session'
        set -g @resurrect-capture-pane-contents 'on'
        set -g @resurrect-processes 'ssh lazygit yazi'
        set -g @resurrect-dir '~/.tmux/resurrect'
      '';
    }
    {
      plugin = continuum;
      extraConfig = ''
        set -g @continuum-restore 'on'
      '';
    }
    { plugin = tmux-fzf; }
  ];
in
{
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    clock24 = false;
    escapeTime = 0;
    historyLimit = 2000;
    keyMode = "vi";
    mouse = true;
    newSession = true;
    prefix = "C-a";
    sensibleOnTop = true;
    terminal = "xterm-256color";
    inherit plugins;
  };
}
