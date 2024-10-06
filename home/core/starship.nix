{ config, lib, ... }:
{
  home = {
    sessionVariables = {
      STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";
    };
  };

  programs.starship =
    let
      elemsConcatted = lib.concatStrings (
        map (s: "\$${s}") [
          "hostname"
          "username"
          "directory"
          "shell"
          "nix_shell"
          "git_branch"
          "git_commit"
          "git_state"
          "git_status"
          "jobs"
          "cmd_duration"
        ]
      );
    in
    {
      enable = true;

      settings = {
        scan_timeout = 2;
        command_timeout = 2000;
        add_newline = true;
        line_break.disabled = false;

        format = "${elemsConcatted}\n$character";

        hostname = {
          ssh_only = true;
          disabled = false;
          format = "@[$hostname](bold blue) ";
        };

        # configure specific elements
        character = {
          error_symbol = "[](bold red)";
          success_symbol = "[](bold green)";
          vicmd_symbol = "[](bold yellow)";
          format = "$symbol [|](bold bright-black) ";
        };

        username = {
          format = "[$user]($style) in ";
        };

        # git
        git_commit.commit_hash_length = 7;
        git_branch.style = "bold purple";
        git_status = {
          style = "red";
          ahead = "⇡ ";
          behind = "⇣ ";
          conflicted = " ";
          renamed = "»";
          deleted = "✘ ";
          diverged = "⇆ ";
          modified = "!";
          stashed = "≡";
          staged = "+";
          untracked = "?";
        };
      };
    };
}
