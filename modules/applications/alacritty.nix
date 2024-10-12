{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  cfg = config.syscfg.applications;
in
{
  options.syscfg.applications.alacritty.enable = lib.mkOption {
    description = "Enables Alacritty Terminal";
    type = lib.types.bool;
    default = config.syscfg.graphics.apps;
  };
  config = lib.mkIf cfg.alacritty.enable {
    home-manager.users.${vars.user} = {
      programs.alacritty = {
        enable = true;
        package = pkgs.alacritty;

        settings = {
          cursor = {
            style = {
              shape = "Block";
              blinking = "Off";
            };
          };

          font = {
            size = 13.0;

            glyph_offset = {
              x = 0;
              y = 1;
            };

            normal = {
              family = "JetBrainsMono Nerd Font Mono";
            };
            bold = {
              family = "JetBrainsMono Nerd Font Mono";
              style = "Bold";
            };
            italic = {
              family = "JetBrainsMono Nerd Font Mono";
              style = "italic";
            };
            bold_italic = {
              family = "JetBrainsMono Nerd Font Mono";
              style = "bold_italic";
            };
          };

          keyboard = {
            bindings = [
              {
                key = "Q";
                mods = "Command";
                action = "Quit";
              }
              {
                key = "W";
                mods = "Command";
                action = "Quit";
              }
              {
                key = "N";
                mods = "Command";
                action = "CreateNewWindow";
              }
            ];
          };

          mouse = {
            hide_when_typing = false;
          };

          window = {
            padding = {
              x = 10;
              y = 10;
            };

            dynamic_padding = true;
            dynamic_title = true;
            opacity = 0.98;
          };
        };
      };
    };
  };
}
