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
            enableZshIntegration = true;
            settings = lib.mkDefault {
              format = lib.concatStrings [
                "$username"
                "$hostname"
                "$directory"
                "$git_branch"
                "$git_state"
                "$git_status"
                "$nix_shell"
                "$fill"
                "$python"
                "$golang"
                "$status"
                "$line_break"
                "$character"
              ];

              fill.symbol = " ";
              hostname.ssh_symbol = "";
              python.format = "([ $virtualenv]($style)) ";
              rust.symbol = " ";
              status.disabled = false;
              username.format = "[$user]($style)@";

              character = {
                success_symbol = "[❯](purple)";
                error_symbol = "[❯](red)";
                vicmd_symbol = "[❯](green)";
              };

              directory = {
                read_only = " ";
                home_symbol = " ~";
                style = "blue";
                truncate_to_repo = false;
                truncation_length = 5;
                truncation_symbol = ".../";
              };

              docker_context.symbol = " ";

              git_branch = {
                symbol = " ";
                format = "[ $branch]($style) ";
                style = "green";
              };

              git_status = {
                deleted = "✗";
                modified = "✶";
                staged = "✓";
                stashed = "≡";
              };

              git_state = {
                format = "\([$state( $progress_current/$progress_total)]($style)\) ";
                style = "bright-black";
              };

              golang = {
                symbol = " ";
                format = "[$symbol$version](cyan bold) ";
              };

              kubernetes = {
                disabled = false;
                format = "[$symbol$context](cyan bold) ";
              };

              nix_shell = {
                disabled = false;
                symbol = "❄️ ";
                format = "via [$symbol\($name\)]($style)";
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
