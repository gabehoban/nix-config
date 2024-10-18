{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
let
  cfg = config.syscfg.shell;

  zsh-histdb-skim = pkgs.callPackage ../../pkgs/zsh-skim-histdb.nix { };
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
        home.packages = [ pkgs.sqlite-interactive ];
        programs = {
          zsh = {
            enable = true;
            autocd = true;
            enableVteIntegration = true;
            dotDir = ".config/zsh";
            history = {
              path = "\${XDG_DATA_HOME-$HOME/.local/share}/zsh/history";
              save = 1000500;
              size = 1000000;
            };
            initExtra = lib.readFile ./zshrc;
            initExtraFirst = ''
              HISTDB_FILE=''${XDG_DATA_HOME-$HOME/.local/share}/zsh/history.db

              # Do this early so fast-syntax-highlighting can wrap and override this
              if autoload history-search-end; then
                zle -N history-beginning-search-backward-end history-search-end
                zle -N history-beginning-search-forward-end  history-search-end
              fi
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
            sessionVariables = {
              EDITOR = "nvim";
            };
            plugins = [
              {
                # Must be before plugins that wrap widgets, such as zsh-autosuggestions or fast-syntax-highlighting
                name = "fzf-tab";
                src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
              }
              {
                name = "fast-syntax-highlighting";
                src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
              }
              {
                name = "zsh-autosuggestions";
                file = "zsh-autosuggestions.zsh";
                src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
              }
              {
                name = "zsh-histdb";
                src = pkgs.fetchFromGitHub {
                  owner = "larkery";
                  repo = "zsh-histdb";
                  rev = "30797f0c50c31c8d8de32386970c5d480e5ab35d";
                  hash = "sha256-PQIFF8kz+baqmZWiSr+wc4EleZ/KD8Y+lxW2NT35/bg=";
                };
              }
              {
                name = "zsh-histdb-skim";
                src = "${zsh-histdb-skim}/share/zsh-histdb-skim";
              }
            ];
          };
          starship = {
            enable = true;
            settings = {
              add_newline = true;
              format = lib.concatStrings [
                "($username )"
                "($hostname )"
                "$directory "
                "($git_branch )"
                "($git_commit )"
                "$git_state"
                "$git_status"
                "\n$character"
              ];
              command_timeout = 60; # 60ms must be enough. I like a responsive prompt more than additional git information.
              username = {
                format = "[$user]($style)";
                style_root = "bold red";
                style_user = "bold purple";
                aliases.root = "";
              };
              hostname = {
                format = "[$hostname]($style)[$ssh_symbol](green)";
                ssh_only = true;
                ssh_symbol = " 󰣀";
                style = "bold red";
              };
              directory = {
                format = "[$path]($style)[$read_only]($read_only_style)";
                fish_style_pwd_dir_length = 1;
                style = "bold blue";
              };
              character = {
                success_symbol = "\\$";
                error_symbol = "\\$";
                vimcmd_symbol = "[](bold green)";
                vimcmd_replace_one_symbol = "[](bold purple)";
                vimcmd_replace_symbol = "[](bold purple)";
                vimcmd_visual_symbol = "[](bold yellow)";
              };
              git_branch = {
                format = "[$symbol$branch]($style)";
                symbol = " ";
                style = "green";
              };
              git_commit = {
                commit_hash_length = 8;
                format = "[$hash$tag]($style)";
                style = "green";
              };
              git_status = {
                conflicted = "$count";
                ahead = "⇡$count";
                behind = "⇣$count";
                diverged = "⇡$ahead_count⇣$behind_count";
                untracked = "?$count";
                stashed = "\\$$count";
                modified = "!$count";
                staged = "+$count";
                renamed = "→$count";
                deleted = "-$count";
                format = lib.concatStrings [
                  "[($conflicted )](red)"
                  "[($stashed )](magenta)"
                  "[($staged )](green)"
                  "[($deleted )](red)"
                  "[($renamed )](blue)"
                  "[($modified )](yellow)"
                  "[($untracked )](blue)"
                  "[($ahead_behind )](green)"
                ];
              };
              status = {
                disabled = false;
                pipestatus = true;
                pipestatus_format = "$pipestatus => [$int( $signal_name)]($style)";
                pipestatus_separator = "[|]($style)";
                pipestatus_segment_format = "[$status]($style)";
                format = "[$status( $signal_name)]($style)";
                style = "red";
              };
              python = {
                format = "[$symbol$pyenv_prefix($version )(\($virtualenv\) )]($style)";
              };
              cmd_duration = {
                format = "[ $duration]($style)";
                style = "yellow";
              };
              time = {
                format = "[ $time]($style)";
                style = "cyan";
                disabled = false;
              };
            };
          };
          eza = {
            enable = true;
            enableZshIntegration = true;
          };
        };
      };
    })
  ];
}
