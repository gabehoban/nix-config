{
  # common module group
  common-home-manager = import ./common/home-manager.nix;
  common-nix          = import ./common/nix.nix;
  common-packages     = import ./common/packages.nix;
  common-shell        = import ./common/shell.nix;
  common-zram         = import ./common/zram.nix;

  # graphical module group
  gui-gaming          = import ./graphical/gaming.nix;
  gui-gnome           = import ./graphical/gnome.nix;
  gui-misc            = import ./graphical/misc.nix;
  gui-nvidia          = import ./graphical/nvidia.nix;
  gui-pipewire        = import ./graphical/pipewire.nix;
}
