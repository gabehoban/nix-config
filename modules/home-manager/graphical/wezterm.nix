{
  programs.wezterm = {
    enable = true;
    colorSchemes.catppuccin-frappe = {
      ansi = [
        "#51576d"
        "#e78284"
        "#a6d189"
        "#e5c890"
        "#8caaee"
        "#f4b8e4"
        "#81c8be"
        "#b5bfe2"
      ];
      brights = [
        "#626880"
        "#e78284"
        "#a6d189"
        "#e5c890"
        "#8caaee"
        "#f4b8e4"
        "#81c8be"
        "#a5adce"
      ];
      background = "#303446";

      compose_cursor = "#eebebe";
      cursor_bg = "#f2d5cf";
      cursor_border = "#f2d5cf";
      cursor_fg = "#232634";
      foreground = "#c6d0f5";
      scrollbar_thumb = "#626880";
      selection_bg = "#626880";
      selection_fg = "#c6d0f5";
      split = "#737994";
      visual_bell = "#414559";
    };
    extraConfig = ''
      return {
        color_scheme = "catppuccin-frappe",
        font = wezterm.font 'JetBrainsMono Nerd Font',
        window_background_opacity = 0.95,
        enable_scroll_bar = true,
        enable_wayland = false,
      }
    '';
  };
}
