{
  # Common Module Group
  common-home     = import ./common/home.nix;
  common-linux    = import ./common/linux.nix;
  common-darwin   = import ./common/darwin.nix;

  gui-firefox     = import ./graphical/firefox.nix;
  gui-gnome       = import ./graphical/gnome.nix;
  gui-vscode      = import ./graphical/vscode.nix;
  gui-wezterm     = import ./graphical/wezterm.nix;
}
