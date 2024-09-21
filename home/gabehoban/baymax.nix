{ config, outputs, ... }:
{

  imports = [
    ./global
    ./optional/gnome-customizations.nix
    ./optional/desktop-packages.nix
    ./optional/terminator.nix
    ./optional/zsh.nix
    ./optional/vscode-extensions.nix
    ./optional/vscode-settings.nix
    ./optional/security-tooling.nix
  ];

  nixpkgs = {
    overlays = [ outputs.overlays.unstable-packages ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

}
