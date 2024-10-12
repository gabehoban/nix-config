{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
let
  cfg = config.syscfg.development;
in
{
  options.syscfg.development = {
    enable = lib.mkOption {
      description = "Sets up the development environment, compilers, and tools";
      type = lib.types.bool;
      default = false;
    };
    emulation.systems = lib.mkOption {
      description = "List of systems to emulate with binfmt";
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkMerge [
    {
      # We need basic git on all computers, needed for flakes too.
      documentation = lib.mapAttrs (_: lib.mkForce) {
        enable = false;
        doc.enable = false;
        info.enable = false;
        nixos.enable = false;
        man.enable = false;
      };

      home-manager.users."${vars.user}" = {
        programs = {
          git = {
            enable = true;
            package = pkgs.gitAndTools.gitFull;
            delta.enable = true;
            userName = "Gabe Hoban";
            userEmail = "gabehoban@icloud.com";
            signing.key = "3EADE0CB32D1BC80DF96F538AFD8F294983C4F95";
            signing.signByDefault = true;
            extraConfig = {
              core.editor = "nvim";
              init.defaultBranch = "main";

              format.signoff = true;
              commit.verbose = "yes";
              merge.conflictStyle = "zdiff3";

              push.default = "current";
              pull.rebase = true;

              # Sign commits with SSH key
              tag.gpgSign = true;
              commit.gpgSign = true;
            };
          };

          direnv = {
            enable = true;
            enableZshIntegration = true;
            nix-direnv.enable = true;
          };
          nix-index-database.comma.enable = true;
          nix-index.enable = true;
        };

        editorconfig = {
          enable = true;
          settings = {
            "*" = {
              charset = "utf-8";
              end_of_line = "lf";
              trim_trailing_whitespace = true;
              insert_final_newline = true;
              indent_style = "space";
              indent_size = 2;
            };
            "*.go" = {
              indent_style = "tab";
            };
            "Makefile" = {
              indent_style = "tab";
            };
            "*.py" = {
              indent_size = 4;
            };
          };
        };
      };

      # Only include general helpful development tools
      environment.systemPackages = with pkgs; [
        bat
        gdb
        gnupg
        licensor
        minify

        scc
        sqlite

        # git
        gh
        git-absorb
        git-extras
        git-lfs
        git-privacy

        # Nix
        nix-diff
        nix-fast-build
        nix-info
        nix-melt
        nix-output-monitor
        nix-tree
        nixfmt-rfc-style
        nixpkgs-review
      ];
    }
    (lib.mkIf (cfg.emulation.systems != [ ]) {
      environment.systemPackages = with pkgs; [
        imagemagick
        ffmpeg
        OVMF
        qemu_kvm
      ];
      users.users.${vars.user}.extraGroups = [ "docker" ];
      virtualisation.docker.enable = true;
      virtualisation.oci-containers.backend = "docker";

      boot.binfmt.emulatedSystems = cfg.emulation.systems;
    })
  ];
}
