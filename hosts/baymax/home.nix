{ pkgs, inputs, ... }:
{
  imports = builtins.attrValues {
    inherit (inputs.self.homeManagerModules)
      common-home
      common-linux

      gui-firefox
      gui-gnome
      gui-vscode
      gui-wezterm
      ;
  };

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    monaspace
    duf
    glxinfo
    libva-utils
    lutris
    ncdu
    nil
    nvtopPackages.full
    protontricks
    spotify
    vdpauinfo
    vesktop
    vkBasalt
    vlc
    vulkan-tools
    wl-clipboard
  ];

  # Needed for Nerd Fonts to be found
  fonts.fontconfig.enable = true;

  programs.obs-studio.enable = true;
  programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [ obs-vkcapture ];
  programs.nix-index.enable = true;

  home.stateVersion = "24.05";
}
