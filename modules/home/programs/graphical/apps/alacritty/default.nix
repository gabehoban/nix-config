{ pkgs, ... }:
{
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
          family = "FiraCode Nerd Font";
        };
        bold = {
          family = "FiraCode Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "FiraCode Nerd Font";
          style = "italic";
        };
        bold_italic = {
          family = "FiraCode Nerd Font";
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
}
