{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
let
  cfg = config.syscfg.shell;
in
{
  options.syscfg.shell.zsh = lib.mkOption {
    description = "Enables zsh with customisations";
    type = lib.types.bool;
    default = true;
  };
  config = lib.mkMerge [
    # Linux-only configurations
    (lib.mkIf (cfg.zsh && pkgs.stdenv.isLinux) {
      home-manager.users."${vars.user}" = { };
    })
    (lib.mkIf cfg.zsh {
      programs.zsh.enable = true;
      users.users."${vars.user}".shell = pkgs.zsh;
      home-manager.users."${vars.user}" = {
        programs.zsh = {
          enable = true;
          dotDir = ".config/zsh";
          autocd = true;
          enableVteIntegration = true;
          initExtra = ''
            # Load colours and set prompt
            autoload -U colors && colors
            if [[ -n "$NIX_SHELL_PACKAGES" ]]; then
              ps_nix="$fg[cyan]{$(echo $NIX_SHELL_PACKAGES | tr " " "," )} "
            fi
            PS1="$ps_nix%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

            # setup sensible options
            setopt interactivecomments
            setopt magicequalsubst
            setopt nonomatch
            setopt notify
            setopt numericglobsort
            setopt promptsubst

            # enable completion features
            autoload -Uz compinit
            compinit -d ~/.cache/zcompdump
            zstyle ':completion:*:*:*:*:*' menu select
            zstyle ':completion:*' auto-description 'specify: %d'
            zstyle ':completion:*' completer _expand _complete
            zstyle ':completion:*' format 'Completing %d'
            zstyle ':completion:*' group-name \'\'
            zstyle ':completion:*' list-colors \'\'
            zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
            zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
            zstyle ':completion:*' rehash true
            zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
            zstyle ':completion:*' use-compctl false
            zstyle ':completion:*' verbose true
            zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

            # History configurations
            HISTFILE=~/.config/zsh_history/histfile
            HISTSIZE=1000
            SAVEHIST=2000
            setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
            setopt hist_ignore_dups       # ignore duplicated commands history list
            setopt hist_ignore_space      # ignore commands that start with space
            setopt hist_verify            # show command with history expansion to user before running it
            #setopt share_history         # share command history data

            # configure key keybindings
            bindkey -e                                        # emacs key bindings
            bindkey ' ' magic-space                           # do history expansion on space
            bindkey '^U' backward-kill-line                   # ctrl + U
            bindkey '^[[3;5~' kill-word                       # ctrl + Supr
            bindkey '^[[3~' delete-char                       # delete
            bindkey '^[[P' delete-char                        # fix delete for st
            bindkey '^[[1;5C' forward-word                    # ctrl + ->
            bindkey '^[[1;5D' backward-word                   # ctrl + <-
            bindkey '^[[5~' beginning-of-buffer-or-history    # page up
            bindkey '^[[6~' end-of-buffer-or-history          # page down
            bindkey '^[[H' beginning-of-line                  # home
            bindkey '^[[F' end-of-line                        # end
            bindkey '^[[Z' undo                               # shift + tab undo last action
            bindkey '^f' vi-forward-char                      # for auto-complete

            source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
            source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh
            export PATH=/opt/homebrew/bin:$PATH

            function mkcd() {
              if [[ -z $1 ]]; then
                echo "Usage: mkcd <directory>"
                return 1
              fi
              mkdir -p $1 && cd $1
            }

            if [[ $OSTYPE == linux* ]]; then
              alias open="xdg-open"
            fi

            echo "$fg[cyan]Welcome back ${config.syscfg.fullname} to your local terminal."
          '';
          shellAliases = {
            vim = "nvim";
            vi = "nvim";
            yt = "yt-dlp --add-metadata -ic";
            yta = "yt-dlp -f bestaudio/best --add-metadata -xic";

            # Better ls
            ls = lib.mkForce "eza --group-directories-first";
            l = "eza -a -l -h --git --group-directories-first";

            # set color=always for some commands
            grep = "grep --color=always";
            diff = "diff --color=always";
            ip = "ip --color=always";
            tree = "tree -C";
            history = "history 0";
          };
          history = {
            size = 10000000;
          };
          sessionVariables = {
            EDITOR = "nvim";
          };
        };

        # ls replacement
        programs.eza = {
          enable = true;
          enableZshIntegration = true;
        };
        programs.zoxide = {
          enable = true;
          enableZshIntegration = true;
        };
      };
    })
  ];
}
