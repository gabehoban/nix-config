{ pkgs
, inputs
, ...
}: {
  imports = builtins.attrValues {
    inherit (inputs.self.homeManagerModules)
      home
      gnome
      linux
      wezterm
      vscode
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
  programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
    obs-vkcapture
  ];

  programs.mangohud.enable = true;
  programs.mangohud.settings = {
    fps_limit = [ 0 60 30 ];
    toggle_fps_limit = "F1";
    gpu_temp = true;
    gpu_core_clock = true;
    gpu_mem_clock = true;
    gpu_power = true;
    cpu_temp = true;
    cpu_power = true;
    cpu_mhz = true;
    vram = true;
    ram = true;
    fps = true;
    vulkan_driver = true;
    wine = true;
    frame_timing = true;
    position = "middle-right";
  };
  programs.nix-index.enable = true;

  home.stateVersion = "24.05";
}
