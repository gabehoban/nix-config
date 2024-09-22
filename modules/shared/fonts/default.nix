{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    # Desktop Fonts
    material-icons
    material-design-icons
    # Nerd Fonts
    (nerdfonts.override {
      fonts = [
        "CascadiaCode"
        "Iosevka"
        "FiraCode"
        "Monaspace"
        "NerdFontsSymbolsOnly"
      ];
    })
  ];
}
