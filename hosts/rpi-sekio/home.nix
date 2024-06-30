{ pkgs , inputs , ... }: {
  imports = builtins.attrValues {
    inherit (inputs.self.homeManagerModules)
      common-home
      common-linux
      ;
  };

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    monaspace
    duf
    ncdu
    nil
  ];

  # Needed for Nerd Fonts to be found
  fonts.fontconfig.enable = true;

  programs.nix-index.enable = true;
  home.stateVersion = "24.05";
}
